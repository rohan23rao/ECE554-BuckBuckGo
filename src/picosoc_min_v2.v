`timescale 1ns / 1ps

module picosoc_min(
    input  wire         clk,
    input  wire         resetn,

    // SDRAM interface pins
    output wire         clk143hz_shift50_1_clk,
    output wire         sdram_pll_reset_source_reset,
    output wire [12:0]  sdram_wire_addr,
    output wire [1:0]   sdram_wire_ba,
    output wire         sdram_wire_cas_n,
    output wire         sdram_wire_cke,
    output wire         sdram_wire_cs_n,
    inout  wire [15:0]  sdram_wire_dq,
    output wire [1:0]   sdram_wire_dqm,
    output wire         sdram_wire_ras_n,
    output wire         sdram_wire_we_n,
	
	    //////////// Audio //////////
    input                AUD_ADCDAT,
    inout                AUD_ADCLRCK,
    inout                AUD_BCLK,
    output               AUD_DACDAT,
    inout                AUD_DACLRCK,
    output               AUD_XCK,
	
	    //////////// I2C for Audio and Video-In //////////
    output               FPGA_I2C_SCLK,
    inout                FPGA_I2C_SDAT,
	
	 //////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,
	
	    //////////// KEY //////////
    input       [3:0]    KEY,

    //////////// LED //////////
    output      [9:0]    LEDR,

    // Simple debug output
    output reg  [127:0] display_data
);

    //--------------------------------------------------------------------------
    // Parameters
    //--------------------------------------------------------------------------
    parameter integer MEM_WORDS     = 256;
    parameter [31:0]  STACKADDR     = 4*MEM_WORDS;
    parameter [31:0]  PROGADDR_RESET= 32'h0000_0000;

    //--------------------------------------------------------------------------
    // CPU <-> Memory interface
    //--------------------------------------------------------------------------
    wire         mem_valid;
    wire         mem_instr;
    wire         mem_ready;
    wire [31:0]  mem_addr;
    wire [31:0]  mem_wdata;
    wire [3:0]   mem_wstrb;
    wire [31:0]  mem_rdata;

    wire         vmem_valid;
    // derive scalar-RAM signals
    wire         rom_sel = mem_valid && mem_instr;
	wire         input_io_sel = (mem_valid && !mem_instr) && (mem_addr == 32'hF000_0000);
    wire         output_io_sel = (mem_valid && !mem_instr) && (mem_addr == 32'hFF01_0000);
	wire         char_x_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100000);
	wire         char_y_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100004);
	wire         obstacle_x_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100008);
	wire         score_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF10000c);
	wire         status_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100010);
	wire 		 obstacle_height_bottom_sel = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100014);
	wire         obstacle_height_top_sel    = mem_valid && (!mem_instr) && (mem_addr == 32'hFF100018);

	wire         vga_sel = char_x_sel || char_y_sel || obstacle_x_sel || score_sel || status_sel || obstacle_height_bottom_sel || obstacle_height_top_sel;
	wire         ram_sel = ((mem_valid && !mem_instr) || vmem_valid) && (~output_io_sel) && (~input_io_sel) && (~vga_sel);
	

	
	
    wire         mem_write_cpu = ram_sel && (|mem_wstrb);
    wire         mem_read_cpu  = ram_sel && mem_valid && !mem_write_cpu;

    reg [9:0] char_x_reg;
	reg [9:0] char_y_reg;
	reg [10:0] obstacle_x_reg;
	reg [15:0] score_reg; // score register
	reg 	   game_status_reg;
	reg [9:0] obstacle_height_bottom_reg;
	reg [9:0] obstacle_height_top_reg;



    //--------------------------------------------------------------------------
    // PicoRV32 Core + PCPI (VPU) interface
    //--------------------------------------------------------------------------
    wire        pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    reg         pcpi_wr;
    reg  [31:0] pcpi_rd;
    wire        pcpi_wait;
    wire        pcpi_ready;

    picorv32 #(
        .ENABLE_REGS_16_31(1),
        .ENABLE_REGS_DUALPORT(0),
        .TWO_STAGE_SHIFT   (0),
        .BARREL_SHIFTER    (1),
        .PROGADDR_RESET    (PROGADDR_RESET),
        .STACKADDR         (STACKADDR)
    ) cpu (
        .clk         (clk),
        .resetn      (resetn),
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata),

        // PCPI interface for VPU
        .pcpi_valid  (pcpi_valid),
        .pcpi_insn   (pcpi_insn),
        .pcpi_rs1    (pcpi_rs1),
        .pcpi_rs2    (pcpi_rs2),
        .pcpi_wr     (pcpi_wr),    // we will drive this low for no scalar write
        .pcpi_rd     (pcpi_rd),
        .pcpi_wait   (pcpi_wait),
        .pcpi_ready  (pcpi_ready)
    );

    // VPU <-> top module connections
    
    wire         dm_v_write;
    wire [31:0]  vdata_addr;
    wire [127:0] v_store_data;
    wire [31:0]  v_load_data_0, v_load_data_1, v_load_data_2, v_load_data_3;
	wire         out_io_waitrequest;

    // pack the 128 bit vector readback
    wire [127:0] v_load_data = {
        v_load_data_3,
        v_load_data_2,
        v_load_data_1,
        v_load_data_0
    };

    // compute per‑lane byte addresses (word aligned)
    wire [31:0] data_addr0 = vdata_addr + 0*4;
    wire [31:0] data_addr1 = vdata_addr + 1*4;
    wire [31:0] data_addr2 = vdata_addr + 2*4;
    wire [31:0] data_addr3 = vdata_addr + 3*4;

    // instantiate the VPU
    vpu_zve32x #(
        .NUM_LANES (4),
        .ELEM_WIDTH(32)
    ) pico_vpu (
        .clk            (clk),
        .rst_n          (resetn),
        .instr          (pcpi_insn),
        .instr_valid    (pcpi_valid),
        .rs1_value      (pcpi_rs1),
        .rs2_value      (pcpi_rs2),
        .mem_req_valid  (vmem_valid),
        .mem_req_rw     (dm_v_write),
        .mem_addr       (vdata_addr),
        .mem_wdata      (v_store_data),
        .mem_req_ready  (1'b1),
        .mem_resp_valid (mem_ready),
        .mem_rdata      (v_load_data),
        .vpu_active     (pcpi_wait),
        .done           (pcpi_ready)
    );

    // drive back the scalar writeback flags
    // (no scalar register writes from VPU, so pcpi_wr stays 0)
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pcpi_wr <= 1'b0;
            pcpi_rd <= 32'b0;
        end else begin
            // finish the PCPI handshake without writing a scalar result
            pcpi_wr <= 1'b0;
            pcpi_rd <= 32'b0;
        end
    end
	
	// Game registers
	always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        char_x_reg <= 10'd100;
        char_y_reg <= 11'd300;
        obstacle_x_reg <= 10'd640;
        score_reg <= 16'd0;
        game_status_reg <= 1'b0;
        obstacle_height_bottom_reg <= 10'd80;
        obstacle_height_top_reg <= 10'd80;
    end else begin
        if (char_x_sel) begin
            // char_x_reg <= mem_wdata[9:0];
            char_x_reg <= 10'd100;
        end else if (char_y_sel) begin
            char_y_reg <= mem_wdata[9:0];
        end else if (obstacle_x_sel) begin
            obstacle_x_reg <= mem_wdata[9:0];
        end else if (score_sel) begin
            score_reg <= mem_wdata[15:0];
        end else if (status_sel) begin
            game_status_reg <= mem_wdata[0];
        end else if (obstacle_height_bottom_sel) begin
			obstacle_height_bottom_reg <= mem_wdata[9:0];
		end else if (obstacle_height_top_sel) begin	
			obstacle_height_top_reg <= mem_wdata[9:0];
		end
    end
end

/*	
reg [23:0] frame_counter;      // For animation speed
reg [23:0] score_counter;      // For score update speed


always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        char_x_reg <= 10'd100;
        char_y_reg <= 10'd300;
        obstacle_x_reg <= 10'd640;
        score_reg <= 16'd0;
        frame_counter <= 24'd0;
        score_counter <= 24'd0;
    end else begin
        frame_counter <= frame_counter + 1;
        score_counter <= score_counter + 1;

        // Character movement every ~400,000 clocks (~16ms)
        if (frame_counter == 24'd400_000) begin
            frame_counter <= 24'd0;

            // Character bouncing
            if (char_y_reg >= 350)
                char_y_reg <= 300;
            else
                char_y_reg <= char_y_reg + 1;

            // Obstacle movement
            if (obstacle_x_reg <= 2)
                obstacle_x_reg <= 640;
            else
                obstacle_x_reg <= obstacle_x_reg - 2;
        end

        // Score increment every ~6 million clocks (~240ms ≈ 4 times per second)
        if (score_counter == 24'd6_000_000) begin
            score_counter <= 24'd0;
            score_reg <= score_reg + 1;
        end

        // CPU writes still allowed
        if (char_x_sel) begin
            char_x_reg <= mem_wdata[9:0];
        end else if (char_y_sel) begin
            char_y_reg <= mem_wdata[9:0];
        end else if (obstacle_x_sel) begin
            obstacle_x_reg <= mem_wdata[9:0];
        end else if (score_sel) begin
            score_reg <= mem_wdata[15:0];
        end
    end
end
*/



	wire [31:0]  rom_rdata;
    //--------------------------------------------------------------------------
    // Instruction ROM
    //--------------------------------------------------------------------------
    ROM rom_inst (
        .clk_rom_clk         (clk),
        .rom_slave_address   (mem_addr[11:2]),
        .rom_slave_debugaccess(1'b0),
        .rom_slave_clken     (rom_sel),
        .rom_slave_chipselect(rom_sel),
        .rom_slave_write     (1'b0),
        .rom_slave_readdata  (rom_rdata),
        .rom_slave_writedata (32'b0),
        .rom_slave_byteenable(4'b1111),
        .rst_rom_reset       (~resetn)
    );

    //--------------------------------------------------------------------------
    // Unified RAM/SDRAM wrapper
    //--------------------------------------------------------------------------
    wire        mem_waitrequest;
    wire        sdram_readdatavalid;
	wire 		sdram_selected;
    wire [31:0] scalar_rdata;

    memory_wrapper full_memory (
        .clk                       (clk),
        .resetn                    (resetn),
        .mem_sel                   (ram_sel),
        .mem_addr                  (mem_addr),
        .mem_wdata                 (mem_wdata),
        .mem_wstrb                 (mem_wstrb),
        .mem_read                  (mem_read_cpu),
        .mem_write                 (mem_write_cpu),
        .mem_rdata                 (scalar_rdata),
        .mem_waitrequest           (mem_waitrequest),
        .sdram_selected            (sdram_selected),
        .sdram_readdatavalid       (sdram_readdatavalid),

        // Vector ports
        .vpu_active                (pcpi_wait),
        .dm_v_write                (dm_v_write),
        .data_addr0                (data_addr0),
        .data_addr1                (data_addr1),
        .data_addr2                (data_addr2),
        .data_addr3                (data_addr3),
        .v_store_data_0            (v_store_data[ 31:  0]),
        .v_store_data_1            (v_store_data[ 63: 32]),
        .v_store_data_2            (v_store_data[ 95: 64]),
        .v_store_data_3            (v_store_data[127: 96]),
        .v_load_data_0             (v_load_data_0),
        .v_load_data_1             (v_load_data_1),
        .v_load_data_2             (v_load_data_2),
        .v_load_data_3             (v_load_data_3),

        // SDRAM pins
        .clk143hz_shift50_1_clk    (clk143hz_shift50_1_clk),
        .sdram_pll_reset_source_reset(sdram_pll_reset_source_reset),
        .sdram_wire_addr           (sdram_wire_addr),
        .sdram_wire_ba             (sdram_wire_ba),
        .sdram_wire_cas_n          (sdram_wire_cas_n),
        .sdram_wire_cke            (sdram_wire_cke),
        .sdram_wire_cs_n           (sdram_wire_cs_n),
        .sdram_wire_dq             (sdram_wire_dq),
        .sdram_wire_dqm            (sdram_wire_dqm),
        .sdram_wire_ras_n          (sdram_wire_ras_n),
        .sdram_wire_we_n           (sdram_wire_we_n)
    );
	
	output_io out_fifo (
		.clk_clk(clk),                    //            clk.clk
		.output_fifo_in_writedata(mem_wdata),   // output_fifo_in.writedata
		.output_fifo_in_write(output_io_sel),       //               .write
		.output_fifo_in_waitrequest(out_io_waitrequest), //               .waitrequest
		.reset_reset_n(resetn)               //          reset.reset_n
	);
	
	wire audio_valid;
	//assign audio_valid = 1'b1;
	wire [31:0]audio_data;
	
	//assign audio_data = 32'd6000;
	
	input_audio input_io(
    //////////// Audio //////////
    .AUD_ADCDAT(AUD_ADCDAT),
    .AUD_ADCLRCK(AUD_ADCLRCK),
    .AUD_BCLK(AUD_BCLK),
    .AUD_DACDAT(AUD_DACDAT),
    .AUD_DACLRCK(AUD_DACLRCK),
    .AUD_XCK(AUD_XCK),

    .rst_n(resetn),
    .clk(clk),
    
    // CPU interface
    .read_req(input_io_sel),
    .read_valid(audio_valid),
    .read_data(audio_data),

    //////////// I2C for Audio and Video-In //////////
    .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
    .FPGA_I2C_SDAT(FPGA_I2C_SDAT),

    //////////// KEY //////////
    .KEY(KEY),

    //////////// LED //////////
    .LEDR(LEDR)
);

wire VGA_clk;
assign VGA_CLK = VGA_clk;

VGA VGA_pll (
		.clk_clk(clk),                        //                      clk.clk
		.reset_reset_n(resetn),                  //                    reset.reset_n
		.video_pll_0_reset_source_reset(), // video_pll_0_reset_source.reset
		.video_pll_0_vga_clk_clk(VGA_clk)         //      video_pll_0_vga_clk.clk
	);
	

// When you instantiate game_top
game_top game(
    .clk(VGA_clk),
    .rst_n(resetn),
    .char_x(char_x_reg),
    .char_y(char_y_reg),
    .obstacle_x(obstacle_x_reg),
    .score(score_reg),
    .game_status(game_status_reg),
    .obstacle_height_bottom(obstacle_height_bottom_reg),
    .obstacle_height_top(obstacle_height_top_reg),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_H_SYNC(VGA_HS),
    .VGA_V_SYNC(VGA_VS),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_BLANK(VGA_BLANK_N),
    .KEY(KEY)
);



      
    // combine ROM vs RAM read data
    assign mem_rdata = rom_sel? rom_rdata
                 :input_io_sel? audio_data
                 :scalar_rdata;
    assign mem_waitrequest = ram_sel ? mem_waitrequest
                                     : 1'b0;
   
	reg ram_valid;
	reg rom_valid;   
	reg output_io_valid;
	reg game_valid;
	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			ram_valid <= 1'b0;
			rom_valid <= 1'b0;
			output_io_valid <= 1'b0;
			game_valid <= 1'b0;
			//audio_valid <= 1'b0;
		end else begin
			ram_valid <= ram_sel;
			rom_valid <= rom_sel;
			output_io_valid <= ~out_io_waitrequest;
			game_valid <= vga_sel;
			//audio_valid <= input_io_sel;
		end
	end



// Memory ready signal
	assign mem_ready =
    ((~sdram_selected) && ram_valid) ||
    (rom_valid) || 
    (sdram_selected && sdram_readdatavalid) ||
	(output_io_sel && output_io_valid) || 
	(input_io_sel && audio_valid) ||
	(vga_sel && game_valid);  


    //--------------------------------------------------------------------------
    // Optional debug: show VPU store on LEDs
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
	   if(audio_valid)begin
        display_data <= audio_data;
	   end
    end

endmodule
