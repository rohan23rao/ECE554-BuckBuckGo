
module obstacle (
	clk_clk,
	reset_reset_n,
	onchip_memory2_0_s1_address,
	onchip_memory2_0_s1_clken,
	onchip_memory2_0_s1_chipselect,
	onchip_memory2_0_s1_write,
	onchip_memory2_0_s1_readdata,
	onchip_memory2_0_s1_writedata,
	onchip_memory2_0_s1_byteenable);	

	input		clk_clk;
	input		reset_reset_n;
	input	[9:0]	onchip_memory2_0_s1_address;
	input		onchip_memory2_0_s1_clken;
	input		onchip_memory2_0_s1_chipselect;
	input		onchip_memory2_0_s1_write;
	output	[31:0]	onchip_memory2_0_s1_readdata;
	input	[31:0]	onchip_memory2_0_s1_writedata;
	input	[3:0]	onchip_memory2_0_s1_byteenable;
endmodule
