// ledreg.v

module ledreg( clk, nreset, wr_en, rd_en, data_in, data_out, led_port); 
    
// Inputs  
input  clk;            
input  nreset;          
input  wr_en;           
input  rd_en;            
input  [7:0] data_in;  
  
// output  
output [7:0] data_out;  
output [7:0] led_port;  //path to led connection
  
// reg  
reg [7:0] ledioreg;   // the io register 
reg [7:0] data_out;  
wire [7:0] led_port;

// map led register to leds
assign led_port = ledioreg;

// read led register
always @(posedge clk, negedge nreset) 
    begin : READ_GEN 
        if(nreset == 1'b0)
            begin
                data_out <= 8'h00;
            end
        else if(rd_en)
            begin  
                data_out <= ledioreg; 
end           end 

// write led register 
always @(posedge clk, negedge nreset) 
    begin : WRITE_GEN 
        if(nreset == 1'b0)
            begin
                ledioreg <= 8'h00;
            end
        else if(wr_en)
            begin  
               	ledioreg <= data_in;
            end     	 
end 
endmodule