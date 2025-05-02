
module output_io (
	clk_clk,
	reset_reset_n,
	output_fifo_in_writedata,
	output_fifo_in_write,
	output_fifo_in_waitrequest,
	output_fifo_in_csr_address,
	output_fifo_in_csr_read,
	output_fifo_in_csr_writedata,
	output_fifo_in_csr_write,
	output_fifo_in_csr_readdata);	

	input		clk_clk;
	input		reset_reset_n;
	input	[31:0]	output_fifo_in_writedata;
	input		output_fifo_in_write;
	output		output_fifo_in_waitrequest;
	input	[2:0]	output_fifo_in_csr_address;
	input		output_fifo_in_csr_read;
	input	[31:0]	output_fifo_in_csr_writedata;
	input		output_fifo_in_csr_write;
	output	[31:0]	output_fifo_in_csr_readdata;
endmodule
