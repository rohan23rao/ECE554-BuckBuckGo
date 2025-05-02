
module background_data (
	onchip_memory2_0_clk1_clk,
	onchip_memory2_0_reset1_reset,
	onchip_memory2_0_reset1_reset_req,
	onchip_memory2_0_s1_address,
	onchip_memory2_0_s1_debugaccess,
	onchip_memory2_0_s1_clken,
	onchip_memory2_0_s1_chipselect,
	onchip_memory2_0_s1_write,
	onchip_memory2_0_s1_readdata,
	onchip_memory2_0_s1_writedata);	

	input		onchip_memory2_0_clk1_clk;
	input		onchip_memory2_0_reset1_reset;
	input		onchip_memory2_0_reset1_reset_req;
	input	[18:0]	onchip_memory2_0_s1_address;
	input		onchip_memory2_0_s1_debugaccess;
	input		onchip_memory2_0_s1_clken;
	input		onchip_memory2_0_s1_chipselect;
	input		onchip_memory2_0_s1_write;
	output	[7:0]	onchip_memory2_0_s1_readdata;
	input	[7:0]	onchip_memory2_0_s1_writedata;
endmodule
