
module RAM (
	clk_ram_clk,
	ram_slave_address,
	ram_slave_clken,
	ram_slave_chipselect,
	ram_slave_write,
	ram_slave_readdata,
	ram_slave_writedata,
	ram_slave_byteenable,
	rst_ram_reset,
	rst_ram_reset_req);	

	input		clk_ram_clk;
	input	[9:0]	ram_slave_address;
	input		ram_slave_clken;
	input		ram_slave_chipselect;
	input		ram_slave_write;
	output	[31:0]	ram_slave_readdata;
	input	[31:0]	ram_slave_writedata;
	input	[3:0]	ram_slave_byteenable;
	input		rst_ram_reset;
	input		rst_ram_reset_req;
endmodule
