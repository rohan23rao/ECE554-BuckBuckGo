	audio_system u0 (
		.audio_0_external_interface_ADCDAT                           (<connected-to-audio_0_external_interface_ADCDAT>),                           //                      audio_0_external_interface.ADCDAT
		.audio_0_external_interface_ADCLRCK                          (<connected-to-audio_0_external_interface_ADCLRCK>),                          //                                                .ADCLRCK
		.audio_0_external_interface_BCLK                             (<connected-to-audio_0_external_interface_BCLK>),                             //                                                .BCLK
		.audio_0_external_interface_DACDAT                           (<connected-to-audio_0_external_interface_DACDAT>),                           //                                                .DACDAT
		.audio_0_external_interface_DACLRCK                          (<connected-to-audio_0_external_interface_DACLRCK>),                          //                                                .DACLRCK
		.audio_and_video_config_0_avalon_av_config_slave_address     (<connected-to-audio_and_video_config_0_avalon_av_config_slave_address>),     // audio_and_video_config_0_avalon_av_config_slave.address
		.audio_and_video_config_0_avalon_av_config_slave_byteenable  (<connected-to-audio_and_video_config_0_avalon_av_config_slave_byteenable>),  //                                                .byteenable
		.audio_and_video_config_0_avalon_av_config_slave_read        (<connected-to-audio_and_video_config_0_avalon_av_config_slave_read>),        //                                                .read
		.audio_and_video_config_0_avalon_av_config_slave_write       (<connected-to-audio_and_video_config_0_avalon_av_config_slave_write>),       //                                                .write
		.audio_and_video_config_0_avalon_av_config_slave_writedata   (<connected-to-audio_and_video_config_0_avalon_av_config_slave_writedata>),   //                                                .writedata
		.audio_and_video_config_0_avalon_av_config_slave_readdata    (<connected-to-audio_and_video_config_0_avalon_av_config_slave_readdata>),    //                                                .readdata
		.audio_and_video_config_0_avalon_av_config_slave_waitrequest (<connected-to-audio_and_video_config_0_avalon_av_config_slave_waitrequest>), //                                                .waitrequest
		.audio_and_video_config_0_external_interface_SDAT            (<connected-to-audio_and_video_config_0_external_interface_SDAT>),            //     audio_and_video_config_0_external_interface.SDAT
		.audio_and_video_config_0_external_interface_SCLK            (<connected-to-audio_and_video_config_0_external_interface_SCLK>),            //                                                .SCLK
		.audio_pll_0_audio_clk_clk                                   (<connected-to-audio_pll_0_audio_clk_clk>),                                   //                           audio_pll_0_audio_clk.clk
		.audio_sc_fifo_almost_empty_data                             (<connected-to-audio_sc_fifo_almost_empty_data>),                             //                      audio_sc_fifo_almost_empty.data
		.audio_sc_fifo_almost_full_data                              (<connected-to-audio_sc_fifo_almost_full_data>),                              //                       audio_sc_fifo_almost_full.data
		.clk_clk                                                     (<connected-to-clk_clk>),                                                     //                                             clk.clk
		.reset_reset_n                                               (<connected-to-reset_reset_n>),                                               //                                           reset.reset_n
		.audio_final_fifo_out_data                                   (<connected-to-audio_final_fifo_out_data>),                                   //                            audio_final_fifo_out.data
		.audio_final_fifo_out_valid                                  (<connected-to-audio_final_fifo_out_valid>),                                  //                                                .valid
		.audio_final_fifo_out_ready                                  (<connected-to-audio_final_fifo_out_ready>),                                  //                                                .ready
		.audio_final_fifo_almost_full_data                           (<connected-to-audio_final_fifo_almost_full_data>),                           //                    audio_final_fifo_almost_full.data
		.audio_final_fifo_almost_empty_data                          (<connected-to-audio_final_fifo_almost_empty_data>),                          //                   audio_final_fifo_almost_empty.data
		.audio_final_fifo_in_data                                    (<connected-to-audio_final_fifo_in_data>),                                    //                             audio_final_fifo_in.data
		.audio_final_fifo_in_valid                                   (<connected-to-audio_final_fifo_in_valid>),                                   //                                                .valid
		.audio_final_fifo_in_ready                                   (<connected-to-audio_final_fifo_in_ready>),                                   //                                                .ready
		.audio_sc_fifo_out_data                                      (<connected-to-audio_sc_fifo_out_data>),                                      //                               audio_sc_fifo_out.data
		.audio_sc_fifo_out_valid                                     (<connected-to-audio_sc_fifo_out_valid>),                                     //                                                .valid
		.audio_sc_fifo_out_ready                                     (<connected-to-audio_sc_fifo_out_ready>)                                      //                                                .ready
	);

