// Verilog module for BRAM with partial Avalon memory-mapped read interface 
module mem_wrapper (
    input wire clk,
    input wire reset_n,
    
    // Avalon-MM slave interface
    input wire [31:0] address,      // 32-bit address for 8 rows
    input wire read,                // Read request
    output reg [31:0] readdata,     // 32-bit read data (one row)
    output reg readdatavalid,       // Data valid signal
	 output reg waitrequest          // Busy signal to indicate logic is processing
);

    wire [31:0] mem_rdata;
    reg [7:0] read_address;  // Latched address for the read operation
	 reg [3:0] delay_counter; // Counter for variable delay

    // State machine for variable delay
    reg [1:0] state;
    localparam IDLE = 2'b00,
               WAIT = 2'b01,
               RESPOND = 2'b10;

    // Memory that stores 
	rom memory (
	   .address(read_address),
	   .clock(clk),
	   .q(mem_rdata));

    // State machine for variable delay read response
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            readdatavalid <= 1'b0;
            readdata <= 32'b0;
			   waitrequest <= 1'b0;
            delay_counter <= 4'b0;
        end else begin
            case (state)
                IDLE: begin
                    readdatavalid <= 1'b0;
						  waitrequest <= 1'b0;
                    if (read) begin
                        read_address <= address; // Latch the address
						      delay_counter <= 4'b1010; // Set a delay (e.g., 10 cycles)
                        waitrequest <= 1'b1;
                        state <= WAIT; // Introduce a wait state
                    end
                end
                WAIT: begin
					     if (delay_counter > 0) begin
                        delay_counter <= delay_counter - 1; // Decrement delay counter
                    end else begin
                        state <= RESPOND;
						  end
                end
                RESPOND: begin
                    readdata <= mem_rdata;
                    readdatavalid <= 1'b1; // Indicate valid data
					     waitrequest <= 1'b0;
                    state <= IDLE; // Return to IDLE state
                end
            endcase
        end
    end

endmodule  