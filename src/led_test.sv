`timescale 1ns/1ps

module tb_picosoc_min;

    reg clk;
    reg resetn;
    wire [9:0] ledr;

    // Instantiate DUT (Device Under Test)
    picosoc_min uut (
        .clk(clk),
        .resetn(resetn),
        .ledr(ledr)
    );

    // Clock generation: 50 MHz → 20 ns period
    always #10 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        resetn = 0;

        // Wait for a few cycles with reset low
        #100;

        // Release reset
        resetn = 1;

        // Run simulation long enough to observe LED behavior
        #100000;

       // $finish;
    end

endmodule
