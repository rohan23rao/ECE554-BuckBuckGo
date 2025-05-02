	RAM u0 (
		.clk_ram_clk          (<connected-to-clk_ram_clk>),          //   clk_ram.clk
		.ram_slave_address    (<connected-to-ram_slave_address>),    // ram_slave.address
		.ram_slave_clken      (<connected-to-ram_slave_clken>),      //          .clken
		.ram_slave_chipselect (<connected-to-ram_slave_chipselect>), //          .chipselect
		.ram_slave_write      (<connected-to-ram_slave_write>),      //          .write
		.ram_slave_readdata   (<connected-to-ram_slave_readdata>),   //          .readdata
		.ram_slave_writedata  (<connected-to-ram_slave_writedata>),  //          .writedata
		.ram_slave_byteenable (<connected-to-ram_slave_byteenable>), //          .byteenable
		.rst_ram_reset        (<connected-to-rst_ram_reset>),        //   rst_ram.reset
		.rst_ram_reset_req    (<connected-to-rst_ram_reset_req>)     //          .reset_req
	);

