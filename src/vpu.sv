//-----------------------------------------------------------------------------
// Top‑level VPU in Verilog style with format-aware decode
//-----------------------------------------------------------------------------
module vpu_zve32x
#(
    parameter NUM_LANES  = 4,
    parameter ELEM_WIDTH = 32
)
(
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire [31:0]                 instr,
    input  wire                        instr_valid,
    input  wire [31:0]                 rs1_value,   // scalar base for loads/stores
    input  wire [31:0]                 rs2_value,   // scalar index for stores
    output wire                        vpu_active,
    output reg                         done,

    // memory interface
    output reg                         mem_req_valid,
    output reg                         mem_req_rw,   // 0=read,1=write
    output reg  [31:0]                 mem_addr,
    output reg  [NUM_LANES*ELEM_WIDTH-1:0] mem_wdata,
    input  wire                        mem_req_ready,
    input  wire                        mem_resp_valid,
    input  wire [NUM_LANES*ELEM_WIDTH-1:0] mem_rdata
);
    localparam VLEN = NUM_LANES * ELEM_WIDTH;

    // Pipeline states
    localparam IDLE      = 3'd0;
    localparam DECODE    = 3'd1;
    localparam EXECUTE   = 3'd2;
    localparam MEMORY    = 3'd3;
    localparam WRITEBACK = 3'd4;
    
    reg [2:0] state, next_state;

    // Instruction fields
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [5:0]  funct6;
    reg  [4:0]  rd, rs1, rs2;
    wire [11:0] imm_i;
    wire [11:0] imm_s;
    reg  [11:0] imm;

    // Extract basic fields directly from instruction
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct6 = instr[31:26];
    assign imm_i  = instr[31:20];
    assign imm_s  = {instr[31:25], instr[11:7]};
    
    // VPU active flag
    assign vpu_active = (state != IDLE);

    // Operation flags
    reg is_vadd, is_vsub, is_vmul;
    reg is_vand, is_vor, is_vxor;
    reg is_vsll, is_vsrl, is_vsra;
    reg is_vld,  is_vst,  is_vredsum;

    // Data paths
    wire [VLEN-1:0] vs1_data, vs2_data;
    wire [VLEN-1:0] alu_path_result;
    reg  [VLEN-1:0] alu_result;
    reg  [VLEN-1:0] mem_read_data;
    reg  [VLEN-1:0] wb_data;
    reg  [4:0]      wb_rd;
    reg             wb_valid;
    
    // Reduction temp
    reg [ELEM_WIDTH-1:0] sum_reg;
    integer red_idx;

    // Register file instance
    vregfile #(NUM_LANES, ELEM_WIDTH) rf(
        .clk(clk), 
        .rst_n(rst_n),
        .we(wb_valid), 
        .rd_addr(wb_rd), 
        .wr_data(wb_data),
        .rs1_addr(rs1), 
        .rs2_addr(rs2),
        .rs1_data(vs1_data), 
        .rs2_data(vs2_data)
    );
    
    // ALU instance
    valupath #(NUM_LANES, ELEM_WIDTH) alu_path(
        .vs1(vs1_data), 
        .vs2(vs2_data),
        .op_add(is_vadd), 
        .op_sub(is_vsub), 
        .op_mul(is_vmul),
        .op_and(is_vand), 
        .op_or(is_vor), 
        .op_xor(is_vxor),
        .op_sll(is_vsll), 
        .op_srl(is_vsrl), 
        .op_sra(is_vsra),
        .result(alu_path_result)
    );

    // State transitions
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:      if (instr_valid && (!done))        next_state = DECODE;
            DECODE:                                       next_state = EXECUTE;
            EXECUTE:   if (is_vld || is_vst)              next_state = MEMORY;
                       else                               next_state = WRITEBACK;
            MEMORY:    if (is_vld && mem_resp_valid)      next_state = WRITEBACK;
                       else if (is_vst && mem_req_ready)  next_state = WRITEBACK;
            WRITEBACK:                                    next_state = IDLE;
        endcase
    end

    // Done flag
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            done <= 1'b0;
        else if (state == WRITEBACK) 
            done <= 1'b1;
        else if (state == IDLE)      
            done <= 1'b0;
    end

    // Decode stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd <= 0; rs1 <= 0; rs2 <= 0; imm <= 0;
            is_vadd <= 0; is_vsub <= 0; is_vmul <= 0;
            is_vand <= 0; is_vor  <= 0; is_vxor <= 0;
            is_vsll <= 0; is_vsrl <= 0; is_vsra <= 0;
            is_vld  <= 0; is_vst  <= 0; is_vredsum <= 0;
        end else if (state == DECODE) begin
            rd  <= instr[11:7];
            rs1 <= instr[19:15];
            rs2 <= instr[24:20];
            imm <= (opcode == 7'b0000111) ? imm_i :
                   (opcode == 7'b0100111) ? imm_s : 12'b0;
                   
            // Vector operation decoding
            is_vadd    <= (opcode == 7'b1010111 && funct6 == 6'b000000);
            is_vsub    <= (opcode == 7'b1010111 && funct6 == 6'b000001);
            is_vmul    <= (opcode == 7'b1010111 && funct6 == 6'b100000);
            is_vand    <= (opcode == 7'b1010111 && funct6 == 6'b100100);
            is_vor     <= (opcode == 7'b1010111 && funct6 == 6'b100110);
            is_vxor    <= (opcode == 7'b1010111 && funct6 == 6'b100010);
            is_vsll    <= (opcode == 7'b1010111 && funct6 == 6'b000100);
            is_vsrl    <= (opcode == 7'b1010111 && funct6 == 6'b000101);
            is_vsra    <= (opcode == 7'b1010111 && funct6 == 6'b000110);
            is_vld     <= (opcode == 7'b0000111 && funct3 == 3'b010);
            is_vst     <= (opcode == 7'b0100111 && funct3 == 3'b010);
            is_vredsum <= (opcode == 7'b1010111 && funct6 == 6'b011000);
        end
    end

    // Execute stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            alu_result <= 0;
        else if (state == EXECUTE) begin
            if (is_vredsum) begin
                sum_reg = 0;
                for (red_idx = 0; red_idx < NUM_LANES; red_idx = red_idx + 1)
                    sum_reg = sum_reg + vs2_data[red_idx*ELEM_WIDTH +: ELEM_WIDTH];
                alu_result <= {{(VLEN-ELEM_WIDTH){1'b0}}, sum_reg};
            end else if (!is_vld && !is_vst) begin
                alu_result <= alu_path_result;
            end
        end
    end

    // Memory stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_req_valid <= 0;
            mem_req_rw    <= 0;
            mem_addr      <= 0;
            mem_wdata     <= 0;
            mem_read_data <= 0;
        end else if (state == EXECUTE) begin
            if (is_vld || is_vst) begin
                mem_req_valid <= 1;
                mem_req_rw    <= is_vst;
                mem_addr      <= rs1_value + {{20{imm[11]}}, imm};
                mem_wdata     <= vs2_data;
            end else 
                mem_req_valid <= 0;
        end else if (state == MEMORY) begin
		       mem_req_rw  <= 1'b0;
            if (mem_resp_valid) 
                mem_read_data <= mem_rdata;
            if (mem_req_valid && mem_req_ready) 
                mem_req_valid <= 0;
        end
    end

    // Writeback stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_valid <= 0;
            wb_rd    <= 0;
            wb_data  <= 0;
        end else if (state == WRITEBACK) begin
            wb_valid <= (is_vadd || is_vsub || is_vmul || is_vand || is_vor || is_vxor ||
                         is_vsll || is_vsrl || is_vsra || is_vld || is_vredsum);
            wb_rd    <= rd;
            wb_data  <= is_vld ? mem_read_data : alu_result;
        end else 
            wb_valid <= 0;
    end
endmodule

//-----------------------------------------------------------------------------
// Vector Register File
//-----------------------------------------------------------------------------
module vregfile
#(
    parameter NUM_LANES  = 4,
    parameter ELEM_WIDTH = 32
)
(
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        we,
    input  wire [4:0]                  rd_addr,
    input  wire [NUM_LANES*ELEM_WIDTH-1:0] wr_data,
    input  wire [4:0]                  rs1_addr,
    input  wire [4:0]                  rs2_addr,
    output wire [NUM_LANES*ELEM_WIDTH-1:0] rs1_data,
    output wire [NUM_LANES*ELEM_WIDTH-1:0] rs2_data
);
    reg [NUM_LANES*ELEM_WIDTH-1:0] regs [0:31];
    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j=0; j<32; j=j+1)begin
                regs[j] <= {NUM_LANES*ELEM_WIDTH{1'b0}};
            end    
           /* regs[0] <= 128'h0000_0000_0000_0005;
            regs[1] <= 128'h0000_0000_0000_0015;
            regs[2] <= 128'h0000_0000_0000_0025;
            regs[3] <= 128'h0000_0000_0000_0000;
            regs[4] <= 128'h0000_0000_0000_0055; */
        end else if (we) begin
            regs[rd_addr] <= wr_data;
        end
    end
    assign rs1_data = regs[rs1_addr];
    assign rs2_data = regs[rs2_addr];
endmodule



//-----------------------------------------------------------------------------
// Vector ALU Path
//-----------------------------------------------------------------------------
module valupath
#(
    parameter NUM_LANES  = 4,
    parameter ELEM_WIDTH = 32
)
(
    input  wire [NUM_LANES*ELEM_WIDTH-1:0] vs1,
    input  wire [NUM_LANES*ELEM_WIDTH-1:0] vs2,
    input  wire                           op_add,
    input  wire                           op_sub,
    input  wire                           op_mul,
    input  wire                           op_and,
    input  wire                           op_or,
    input  wire                           op_xor,
    input  wire                           op_sll,
    input  wire                           op_srl,
    input  wire                           op_sra,
    output reg  [NUM_LANES*ELEM_WIDTH-1:0] result
);
    integer i;
    reg signed [ELEM_WIDTH-1:0] a, b;
    reg signed [ELEM_WIDTH-1:0] r_add, r_sub, r_mul;
    reg        [ELEM_WIDTH-1:0] r_and, r_or, r_xor;
    reg        [ELEM_WIDTH-1:0] r_sll, r_srl, r_sra;

    always @* begin
        for (i = 0; i < NUM_LANES; i = i + 1) begin
            a     = vs1[i*ELEM_WIDTH +: ELEM_WIDTH];
            b     = vs2[i*ELEM_WIDTH +: ELEM_WIDTH];
            r_add = a + b;
            r_sub = a - b;
            r_mul = a * b;
            r_and = a & b;
            r_or  = a | b;
            r_xor = a ^ b;
            r_sll = a << b[ELEM_WIDTH-1:0];
            r_srl = a >> b[ELEM_WIDTH-1:0];
            r_sra = a >>> b[ELEM_WIDTH-1:0];

            if      (op_add) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_add;
            else if (op_sub) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_sub;
            else if (op_mul) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_mul;
            else if (op_and) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_and;
            else if (op_or ) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_or;
            else if (op_xor) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_xor;
            else if (op_sll) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_sll;
            else if (op_srl) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_srl;
            else if (op_sra) result[i*ELEM_WIDTH +: ELEM_WIDTH] = r_sra;
            else              result[i*ELEM_WIDTH +: ELEM_WIDTH] = {ELEM_WIDTH{1'b0}};
        end
    end
endmodule
