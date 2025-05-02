	component background_data is
		port (
			onchip_memory2_0_clk1_clk         : in  std_logic                     := 'X';             -- clk
			onchip_memory2_0_reset1_reset     : in  std_logic                     := 'X';             -- reset
			onchip_memory2_0_reset1_reset_req : in  std_logic                     := 'X';             -- reset_req
			onchip_memory2_0_s1_address       : in  std_logic_vector(18 downto 0) := (others => 'X'); -- address
			onchip_memory2_0_s1_debugaccess   : in  std_logic                     := 'X';             -- debugaccess
			onchip_memory2_0_s1_clken         : in  std_logic                     := 'X';             -- clken
			onchip_memory2_0_s1_chipselect    : in  std_logic                     := 'X';             -- chipselect
			onchip_memory2_0_s1_write         : in  std_logic                     := 'X';             -- write
			onchip_memory2_0_s1_readdata      : out std_logic_vector(7 downto 0);                     -- readdata
			onchip_memory2_0_s1_writedata     : in  std_logic_vector(7 downto 0)  := (others => 'X')  -- writedata
		);
	end component background_data;

	u0 : component background_data
		port map (
			onchip_memory2_0_clk1_clk         => CONNECTED_TO_onchip_memory2_0_clk1_clk,         --   onchip_memory2_0_clk1.clk
			onchip_memory2_0_reset1_reset     => CONNECTED_TO_onchip_memory2_0_reset1_reset,     -- onchip_memory2_0_reset1.reset
			onchip_memory2_0_reset1_reset_req => CONNECTED_TO_onchip_memory2_0_reset1_reset_req, --                        .reset_req
			onchip_memory2_0_s1_address       => CONNECTED_TO_onchip_memory2_0_s1_address,       --     onchip_memory2_0_s1.address
			onchip_memory2_0_s1_debugaccess   => CONNECTED_TO_onchip_memory2_0_s1_debugaccess,   --                        .debugaccess
			onchip_memory2_0_s1_clken         => CONNECTED_TO_onchip_memory2_0_s1_clken,         --                        .clken
			onchip_memory2_0_s1_chipselect    => CONNECTED_TO_onchip_memory2_0_s1_chipselect,    --                        .chipselect
			onchip_memory2_0_s1_write         => CONNECTED_TO_onchip_memory2_0_s1_write,         --                        .write
			onchip_memory2_0_s1_readdata      => CONNECTED_TO_onchip_memory2_0_s1_readdata,      --                        .readdata
			onchip_memory2_0_s1_writedata     => CONNECTED_TO_onchip_memory2_0_s1_writedata      --                        .writedata
		);

