module led_wrapper(
    input clk,
    input nreset,
    input wr_en,
    input rd_en,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg [7:0] led_port
);

    reg [7:0] led_reg;

    always @(posedge clk or negedge nreset) begin
        if (!nreset) begin
            led_reg <= 8'h00;
        end else if (wr_en) begin
                led_reg <= data_in;      
           
        end
    end

    always @(*) begin
        led_port = led_reg;
        data_out = rd_en ? led_reg : 8'h00;
    end

endmodule
