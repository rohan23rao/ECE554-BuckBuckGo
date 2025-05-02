
module ROM (
	clk_rom_clk,
	rom_slave_address,
	rom_slave_debugaccess,
	rom_slave_clken,
	rom_slave_chipselect,
	rom_slave_write,
	rom_slave_readdata,
	rom_slave_writedata,
	rom_slave_byteenable,
	rst_rom_reset);	

	input		clk_rom_clk;
	input	[9:0]	rom_slave_address;
	input		rom_slave_debugaccess;
	input		rom_slave_clken;
	input		rom_slave_chipselect;
	input		rom_slave_write;
	output	[31:0]	rom_slave_readdata;
	input	[31:0]	rom_slave_writedata;
	input	[3:0]	rom_slave_byteenable;
	input		rst_rom_reset;
endmodule
