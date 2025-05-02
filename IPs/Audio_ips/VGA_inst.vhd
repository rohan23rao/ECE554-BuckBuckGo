	component VGA is
		port (
			clk_clk                        : in  std_logic := 'X'; -- clk
			reset_reset_n                  : in  std_logic := 'X'; -- reset_n
			video_pll_0_vga_clk_clk        : out std_logic;        -- clk
			video_pll_0_reset_source_reset : out std_logic         -- reset
		);
	end component VGA;

	u0 : component VGA
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                      clk.clk
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                    reset.reset_n
			video_pll_0_vga_clk_clk        => CONNECTED_TO_video_pll_0_vga_clk_clk,        --      video_pll_0_vga_clk.clk
			video_pll_0_reset_source_reset => CONNECTED_TO_video_pll_0_reset_source_reset  -- video_pll_0_reset_source.reset
		);

