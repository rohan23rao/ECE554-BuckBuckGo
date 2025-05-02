	output_io u0 (
		.clk_clk                      (<connected-to-clk_clk>),                      //                clk.clk
		.reset_reset_n                (<connected-to-reset_reset_n>),                //              reset.reset_n
		.output_fifo_in_writedata     (<connected-to-output_fifo_in_writedata>),     //     output_fifo_in.writedata
		.output_fifo_in_write         (<connected-to-output_fifo_in_write>),         //                   .write
		.output_fifo_in_waitrequest   (<connected-to-output_fifo_in_waitrequest>),   //                   .waitrequest
		.output_fifo_in_csr_address   (<connected-to-output_fifo_in_csr_address>),   // output_fifo_in_csr.address
		.output_fifo_in_csr_read      (<connected-to-output_fifo_in_csr_read>),      //                   .read
		.output_fifo_in_csr_writedata (<connected-to-output_fifo_in_csr_writedata>), //                   .writedata
		.output_fifo_in_csr_write     (<connected-to-output_fifo_in_csr_write>),     //                   .write
		.output_fifo_in_csr_readdata  (<connected-to-output_fifo_in_csr_readdata>)   //                   .readdata
	);

