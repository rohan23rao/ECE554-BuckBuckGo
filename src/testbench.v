// `timescale 1 ns / 1 ps

// module testbench;
//     // Testbench signals
//     reg clk = 1;
//     reg resetn = 0;
//     wire trap;
    
//     // Clock generation: 10 ns period (i.e. 100 MHz clock)
//     always #5 clk = ~clk;
    
//     // Reset sequence and simulation control
//     initial begin
//         // Hold reset for 100 clock cycles
//         repeat (100) @(posedge clk);
//         resetn <= 1;
//         // Let simulation run for an additional 1000 cycles
//         repeat (1000) @(posedge clk);
//         $stop;
//     end

//     // Memory interface signals between the CPU and our memory model
//     wire        mem_valid;
//     wire        mem_instr;
//     reg         mem_ready;
//     wire [31:0] mem_addr;
//     wire [31:0] mem_wdata;
//     wire [3:0]  mem_wstrb;
//     reg  [31:0] mem_rdata;
    
//     // Display memory transactions on the console
//     always @(posedge clk) begin
//         if (mem_valid && mem_ready) begin
//             if (mem_instr)
//                 $display("ifetch 0x%08x: 0x%08x", mem_addr, mem_rdata);
//             else if (mem_wstrb)
//                 $display("write  0x%08x: 0x%08x (wstrb=%b)", mem_addr, mem_wdata, mem_wstrb);
//             else
//                 $display("read   0x%08x: 0x%08x", mem_addr, mem_rdata);
//         end
//     end

//     // Instantiate the PicoRV32 CPU
//     picorv32 uut (
//         .clk         (clk        ),
//         .resetn      (resetn     ),
//         .trap        (trap       ),
//         .mem_valid   (mem_valid  ),
//         .mem_instr   (mem_instr  ),
//         .mem_ready   (mem_ready  ),
//         .mem_addr    (mem_addr   ),
//         .mem_wdata   (mem_wdata  ),
//         .mem_wstrb   (mem_wstrb  ),
//         .mem_rdata   (mem_rdata  )
//     );

//     // Simple internal memory model: 256 words (1KB)
//     reg [31:0] memory [0:255];

//     // Initialize memory with a small program:
//     //  0: li      x1,1020      (3fc00093)
//     //  1: sw      x0,0(x1)     (0000a023)
//     //  2: lw      x2,0(x1)     (0000a103)  <-- loop:
//     //  3: addi    x2,x2,1     (00110113)
//     //  4: sw      x2,0(x1)     (0020a023)
//     //  5: j       <loop>       (ff5ff06f)
//     initial begin
//         memory[0] = 32'h3fc00093; 
//         memory[1] = 32'h0000a023; 
//         memory[2] = 32'h0000a103; 
//         memory[3] = 32'h00110113; 
//         memory[4] = 32'h0020a023; 
//         memory[5] = 32'hff5ff06f; 
//     end

//     // Memory read/write behavior
//     always @(posedge clk) begin
//         mem_ready <= 0;
//         if (mem_valid && !mem_ready) begin
//             // Map addresses below 1024 bytes to our internal RAM
//             if (mem_addr < 1024) begin
//                 mem_ready <= 1;
//                 mem_rdata <= memory[mem_addr >> 2];
//                 if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
//                 if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
//                 if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
//                 if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
//             end
//             // You can add additional memory-mapped I/O here if needed.
//         end
//     end

// endmodule



`timescale 1 ns / 1 ps

module testbench;
    // Testbench signals
    reg clk = 1;
    reg resetn = 0;
    wire trap;
    
    // Clock generation: toggle every 5 ns for a 10 ns period (100 MHz)
    always #5 clk = ~clk;
    
    // Reset sequence and simulation control
    initial begin
        // Hold reset for 100 clock cycles
        repeat (100) @(posedge clk);
        resetn <= 1;
        // Let simulation run for an additional 1000 cycles
        repeat (1000) @(posedge clk);
        $stop;
    end

    // Memory interface signals between the CPU and our memory model
    wire        mem_valid;
    wire        mem_instr;
    reg         mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;
    
    // A combinational block that defines the expected memory data
    // for known addresses where our program is located.
    reg [31:0] expected_data;
    always @(*) begin
        case (mem_addr)
            32'h00000000: expected_data = 32'h3fc00093; // li x1,1020
            32'h00000004: expected_data = 32'h0000a023; // sw x0, 0(x1)
            32'h00000008: expected_data = 32'h0000a103; // lw x2, 0(x1)
            32'h0000000c: expected_data = 32'h00110113; // addi x2, x2, 1
            32'h00000010: expected_data = 32'h0020a023; // sw x2, 0(x1)
            32'h00000014: expected_data = 32'hff5ff06f; // j <loop>
            default:      expected_data = 32'hxxxxxxxx; // unknown
        endcase
    end

    // Display memory transactions and expected values
    always @(posedge clk) begin
        if (mem_valid && mem_ready) begin
            if (mem_instr)
                $display("ifetch 0x%08x: 0x%08x (expected: 0x%08x)", mem_addr, mem_rdata, expected_data);
            else if (mem_wstrb)
                $display("write  0x%08x: 0x%08x (wstrb=%b)", mem_addr, mem_wdata, mem_wstrb);
            else
                $display("read   0x%08x: 0x%08x (expected: 0x%08x)", mem_addr, mem_rdata, expected_data);
        end
    end

    // Instantiate the PicoRV32 CPU (unit under test)
    picorv32 uut (
        .clk         (clk        ),
        .resetn      (resetn     ),
        .trap        (trap       ),
        .mem_valid   (mem_valid  ),
        .mem_instr   (mem_instr  ),
        .mem_ready   (mem_ready  ),
        .mem_addr    (mem_addr   ),
        .mem_wdata   (mem_wdata  ),
        .mem_wstrb   (mem_wstrb  ),
        .mem_rdata   (mem_rdata  )
    );

    // Simple internal memory model: 256 words (1KB total)
    reg [31:0] memory [0:255];

    // Load a small program into memory:
    //   0: li      x1,1020      (3fc00093)
    //   1: sw      x0,0(x1)     (0000a023)
    //   2: lw      x2,0(x1)     (0000a103)  <-- loop:
    //   3: addi    x2,x2,1     (00110113)
    //   4: sw      x2,0(x1)     (0020a023)
    //   5: j       <loop>       (ff5ff06f)
    initial begin
        memory[0] = 32'h3fc00093;
        memory[1] = 32'h0000a023;
        memory[2] = 32'h0000a103;
        memory[3] = 32'h00110113;
        memory[4] = 32'h0020a023;
        memory[5] = 32'hff5ff06f;
    end

    // Memory read/write behavior
    always @(posedge clk) begin
        mem_ready <= 0;
        if (mem_valid && !mem_ready) begin
            // Map addresses below 1024 bytes to our internal RAM
            if (mem_addr < 1024) begin
                mem_ready <= 1;
                mem_rdata <= memory[mem_addr >> 2];
                if (mem_wstrb[0])
                    memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1])
                    memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2])
                    memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3])
                    memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
            end
            // (You could add additional memory-mapped I/O here if desired)
        end
    end

endmodule
