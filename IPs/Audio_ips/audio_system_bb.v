
module audio_system (
	audio_0_external_interface_ADCDAT,
	audio_0_external_interface_ADCLRCK,
	audio_0_external_interface_BCLK,
	audio_0_external_interface_DACDAT,
	audio_0_external_interface_DACLRCK,
	audio_and_video_config_0_avalon_av_config_slave_address,
	audio_and_video_config_0_avalon_av_config_slave_byteenable,
	audio_and_video_config_0_avalon_av_config_slave_read,
	audio_and_video_config_0_avalon_av_config_slave_write,
	audio_and_video_config_0_avalon_av_config_slave_writedata,
	audio_and_video_config_0_avalon_av_config_slave_readdata,
	audio_and_video_config_0_avalon_av_config_slave_waitrequest,
	audio_and_video_config_0_external_interface_SDAT,
	audio_and_video_config_0_external_interface_SCLK,
	audio_pll_0_audio_clk_clk,
	audio_sc_fifo_almost_empty_data,
	audio_sc_fifo_almost_full_data,
	clk_clk,
	reset_reset_n,
	audio_final_fifo_out_data,
	audio_final_fifo_out_valid,
	audio_final_fifo_out_ready,
	audio_final_fifo_almost_full_data,
	audio_final_fifo_almost_empty_data,
	audio_final_fifo_in_data,
	audio_final_fifo_in_valid,
	audio_final_fifo_in_ready,
	audio_sc_fifo_out_data,
	audio_sc_fifo_out_valid,
	audio_sc_fifo_out_ready);	

	input		audio_0_external_interface_ADCDAT;
	input		audio_0_external_interface_ADCLRCK;
	input		audio_0_external_interface_BCLK;
	output		audio_0_external_interface_DACDAT;
	input		audio_0_external_interface_DACLRCK;
	input	[1:0]	audio_and_video_config_0_avalon_av_config_slave_address;
	input	[3:0]	audio_and_video_config_0_avalon_av_config_slave_byteenable;
	input		audio_and_video_config_0_avalon_av_config_slave_read;
	input		audio_and_video_config_0_avalon_av_config_slave_write;
	input	[31:0]	audio_and_video_config_0_avalon_av_config_slave_writedata;
	output	[31:0]	audio_and_video_config_0_avalon_av_config_slave_readdata;
	output		audio_and_video_config_0_avalon_av_config_slave_waitrequest;
	inout		audio_and_video_config_0_external_interface_SDAT;
	output		audio_and_video_config_0_external_interface_SCLK;
	output		audio_pll_0_audio_clk_clk;
	output		audio_sc_fifo_almost_empty_data;
	output		audio_sc_fifo_almost_full_data;
	input		clk_clk;
	input		reset_reset_n;
	output	[15:0]	audio_final_fifo_out_data;
	output		audio_final_fifo_out_valid;
	input		audio_final_fifo_out_ready;
	output		audio_final_fifo_almost_full_data;
	output		audio_final_fifo_almost_empty_data;
	input	[15:0]	audio_final_fifo_in_data;
	input		audio_final_fifo_in_valid;
	output		audio_final_fifo_in_ready;
	output	[15:0]	audio_sc_fifo_out_data;
	output		audio_sc_fifo_out_valid;
	input		audio_sc_fifo_out_ready;
endmodule
