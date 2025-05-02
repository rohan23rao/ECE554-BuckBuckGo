	ROM u0 (
		.clk_rom_clk           (<connected-to-clk_rom_clk>),           //   clk_rom.clk
		.rom_slave_address     (<connected-to-rom_slave_address>),     // rom_slave.address
		.rom_slave_debugaccess (<connected-to-rom_slave_debugaccess>), //          .debugaccess
		.rom_slave_clken       (<connected-to-rom_slave_clken>),       //          .clken
		.rom_slave_chipselect  (<connected-to-rom_slave_chipselect>),  //          .chipselect
		.rom_slave_write       (<connected-to-rom_slave_write>),       //          .write
		.rom_slave_readdata    (<connected-to-rom_slave_readdata>),    //          .readdata
		.rom_slave_writedata   (<connected-to-rom_slave_writedata>),   //          .writedata
		.rom_slave_byteenable  (<connected-to-rom_slave_byteenable>),  //          .byteenable
		.rst_rom_reset         (<connected-to-rst_rom_reset>)          //   rst_rom.reset
	);

