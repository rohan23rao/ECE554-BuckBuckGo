`timescale 1 ns / 1 ps

module top_testbench;

    reg clk = 1;
    reg resetn = 0;
    
    // Instantiate minimal PicoSoC (no AXI, no RAM)
    wire [9:0] ledr;
    picosoc_min dut (
         .clk    (clk),
         .resetn (resetn),
         .ledr   (ledr)
    );
    
    always #5 clk = ~clk;
    
    // Preload "RAM" with a small program -- from testbench_ez on Github
    initial begin
         dut.memory.mem[0] = 32'h100000B7; // lui x1, 0x10000 -> x1 = 0x10000000 (LED peripheral base address)
         dut.memory.mem[1] = 32'h00000113; // addi x2, x0, 0 -> x2 = 0
         dut.memory.mem[2] = 32'h00110113; // addi x2, x2, 1 -> x2 = 1
         dut.memory.mem[3] = 32'h0020a023; // sw   x2, 0(x1) -> store 1 to address 0x10000000
         dut.memory.mem[4] = 32'h0000006F; // jal  x0, 0 -> jump to self (halt)
    end
    
    // Reset and simulation control.
    initial begin
        repeat (100) @(posedge clk);  
        resetn <= 1;
        repeat (1000) @(posedge clk); 
        
        // Check LED output. Expected: 10'b0000000001
        $display("Final LEDR: Actual = %b, Expected = %b", ledr, 10'b0000000001);
        
        // Check preloaded program
        $display("Memory[0]: Actual = %h, Expected = 100000B7", dut.memory.mem[0]);
        $display("Memory[1]: Actual = %h, Expected = 00000113", dut.memory.mem[1]);
        $display("Memory[2]: Actual = %h, Expected = 00110113", dut.memory.mem[2]);
        $display("Memory[3]: Actual = %h, Expected = 0020A023", dut.memory.mem[3]);
        $display("Memory[4]: Actual = %h, Expected = 0000006F", dut.memory.mem[4]);
        
        $stop;
    end

endmodule
