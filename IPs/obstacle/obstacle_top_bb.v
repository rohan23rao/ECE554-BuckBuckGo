
module obstacle_top (
	onchip_memory2_0_clk1_clk,
	onchip_memory2_0_reset1_reset,
	onchip_memory2_0_reset1_reset_req,
	onchip_memory2_0_s1_address,
	onchip_memory2_0_s1_debugaccess,
	onchip_memory2_0_s1_clken,
	onchip_memory2_0_s1_chipselect,
	onchip_memory2_0_s1_write,
	onchip_memory2_0_s1_readdata,
	onchip_memory2_0_s1_writedata,
	onchip_memory2_0_s1_byteenable);	

	input		onchip_memory2_0_clk1_clk;
	input		onchip_memory2_0_reset1_reset;
	input		onchip_memory2_0_reset1_reset_req;
	input	[10:0]	onchip_memory2_0_s1_address;
	input		onchip_memory2_0_s1_debugaccess;
	input		onchip_memory2_0_s1_clken;
	input		onchip_memory2_0_s1_chipselect;
	input		onchip_memory2_0_s1_write;
	output	[31:0]	onchip_memory2_0_s1_readdata;
	input	[31:0]	onchip_memory2_0_s1_writedata;
	input	[3:0]	onchip_memory2_0_s1_byteenable;
endmodule
