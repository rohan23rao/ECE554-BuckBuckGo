	component audio_system is
		port (
			audio_0_external_interface_ADCDAT                           : in    std_logic                     := 'X';             -- ADCDAT
			audio_0_external_interface_ADCLRCK                          : in    std_logic                     := 'X';             -- ADCLRCK
			audio_0_external_interface_BCLK                             : in    std_logic                     := 'X';             -- BCLK
			audio_0_external_interface_DACDAT                           : out   std_logic;                                        -- DACDAT
			audio_0_external_interface_DACLRCK                          : in    std_logic                     := 'X';             -- DACLRCK
			audio_and_video_config_0_avalon_av_config_slave_address     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- address
			audio_and_video_config_0_avalon_av_config_slave_byteenable  : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			audio_and_video_config_0_avalon_av_config_slave_read        : in    std_logic                     := 'X';             -- read
			audio_and_video_config_0_avalon_av_config_slave_write       : in    std_logic                     := 'X';             -- write
			audio_and_video_config_0_avalon_av_config_slave_writedata   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			audio_and_video_config_0_avalon_av_config_slave_readdata    : out   std_logic_vector(31 downto 0);                    -- readdata
			audio_and_video_config_0_avalon_av_config_slave_waitrequest : out   std_logic;                                        -- waitrequest
			audio_and_video_config_0_external_interface_SDAT            : inout std_logic                     := 'X';             -- SDAT
			audio_and_video_config_0_external_interface_SCLK            : out   std_logic;                                        -- SCLK
			audio_pll_0_audio_clk_clk                                   : out   std_logic;                                        -- clk
			audio_sc_fifo_almost_empty_data                             : out   std_logic;                                        -- data
			audio_sc_fifo_almost_full_data                              : out   std_logic;                                        -- data
			clk_clk                                                     : in    std_logic                     := 'X';             -- clk
			reset_reset_n                                               : in    std_logic                     := 'X';             -- reset_n
			audio_final_fifo_out_data                                   : out   std_logic_vector(15 downto 0);                    -- data
			audio_final_fifo_out_valid                                  : out   std_logic;                                        -- valid
			audio_final_fifo_out_ready                                  : in    std_logic                     := 'X';             -- ready
			audio_final_fifo_almost_full_data                           : out   std_logic;                                        -- data
			audio_final_fifo_almost_empty_data                          : out   std_logic;                                        -- data
			audio_final_fifo_in_data                                    : in    std_logic_vector(15 downto 0) := (others => 'X'); -- data
			audio_final_fifo_in_valid                                   : in    std_logic                     := 'X';             -- valid
			audio_final_fifo_in_ready                                   : out   std_logic;                                        -- ready
			audio_sc_fifo_out_data                                      : out   std_logic_vector(15 downto 0);                    -- data
			audio_sc_fifo_out_valid                                     : out   std_logic;                                        -- valid
			audio_sc_fifo_out_ready                                     : in    std_logic                     := 'X'              -- ready
		);
	end component audio_system;

	u0 : component audio_system
		port map (
			audio_0_external_interface_ADCDAT                           => CONNECTED_TO_audio_0_external_interface_ADCDAT,                           --                      audio_0_external_interface.ADCDAT
			audio_0_external_interface_ADCLRCK                          => CONNECTED_TO_audio_0_external_interface_ADCLRCK,                          --                                                .ADCLRCK
			audio_0_external_interface_BCLK                             => CONNECTED_TO_audio_0_external_interface_BCLK,                             --                                                .BCLK
			audio_0_external_interface_DACDAT                           => CONNECTED_TO_audio_0_external_interface_DACDAT,                           --                                                .DACDAT
			audio_0_external_interface_DACLRCK                          => CONNECTED_TO_audio_0_external_interface_DACLRCK,                          --                                                .DACLRCK
			audio_and_video_config_0_avalon_av_config_slave_address     => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_address,     -- audio_and_video_config_0_avalon_av_config_slave.address
			audio_and_video_config_0_avalon_av_config_slave_byteenable  => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_byteenable,  --                                                .byteenable
			audio_and_video_config_0_avalon_av_config_slave_read        => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_read,        --                                                .read
			audio_and_video_config_0_avalon_av_config_slave_write       => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_write,       --                                                .write
			audio_and_video_config_0_avalon_av_config_slave_writedata   => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_writedata,   --                                                .writedata
			audio_and_video_config_0_avalon_av_config_slave_readdata    => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_readdata,    --                                                .readdata
			audio_and_video_config_0_avalon_av_config_slave_waitrequest => CONNECTED_TO_audio_and_video_config_0_avalon_av_config_slave_waitrequest, --                                                .waitrequest
			audio_and_video_config_0_external_interface_SDAT            => CONNECTED_TO_audio_and_video_config_0_external_interface_SDAT,            --     audio_and_video_config_0_external_interface.SDAT
			audio_and_video_config_0_external_interface_SCLK            => CONNECTED_TO_audio_and_video_config_0_external_interface_SCLK,            --                                                .SCLK
			audio_pll_0_audio_clk_clk                                   => CONNECTED_TO_audio_pll_0_audio_clk_clk,                                   --                           audio_pll_0_audio_clk.clk
			audio_sc_fifo_almost_empty_data                             => CONNECTED_TO_audio_sc_fifo_almost_empty_data,                             --                      audio_sc_fifo_almost_empty.data
			audio_sc_fifo_almost_full_data                              => CONNECTED_TO_audio_sc_fifo_almost_full_data,                              --                       audio_sc_fifo_almost_full.data
			clk_clk                                                     => CONNECTED_TO_clk_clk,                                                     --                                             clk.clk
			reset_reset_n                                               => CONNECTED_TO_reset_reset_n,                                               --                                           reset.reset_n
			audio_final_fifo_out_data                                   => CONNECTED_TO_audio_final_fifo_out_data,                                   --                            audio_final_fifo_out.data
			audio_final_fifo_out_valid                                  => CONNECTED_TO_audio_final_fifo_out_valid,                                  --                                                .valid
			audio_final_fifo_out_ready                                  => CONNECTED_TO_audio_final_fifo_out_ready,                                  --                                                .ready
			audio_final_fifo_almost_full_data                           => CONNECTED_TO_audio_final_fifo_almost_full_data,                           --                    audio_final_fifo_almost_full.data
			audio_final_fifo_almost_empty_data                          => CONNECTED_TO_audio_final_fifo_almost_empty_data,                          --                   audio_final_fifo_almost_empty.data
			audio_final_fifo_in_data                                    => CONNECTED_TO_audio_final_fifo_in_data,                                    --                             audio_final_fifo_in.data
			audio_final_fifo_in_valid                                   => CONNECTED_TO_audio_final_fifo_in_valid,                                   --                                                .valid
			audio_final_fifo_in_ready                                   => CONNECTED_TO_audio_final_fifo_in_ready,                                   --                                                .ready
			audio_sc_fifo_out_data                                      => CONNECTED_TO_audio_sc_fifo_out_data,                                      --                               audio_sc_fifo_out.data
			audio_sc_fifo_out_valid                                     => CONNECTED_TO_audio_sc_fifo_out_valid,                                     --                                                .valid
			audio_sc_fifo_out_ready                                     => CONNECTED_TO_audio_sc_fifo_out_ready                                      --                                                .ready
		);

