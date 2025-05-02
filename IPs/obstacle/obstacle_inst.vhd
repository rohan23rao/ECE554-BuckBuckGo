	component obstacle is
		port (
			clk_clk                        : in  std_logic                     := 'X';             -- clk
			reset_reset_n                  : in  std_logic                     := 'X';             -- reset_n
			onchip_memory2_0_s1_address    : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- address
			onchip_memory2_0_s1_clken      : in  std_logic                     := 'X';             -- clken
			onchip_memory2_0_s1_chipselect : in  std_logic                     := 'X';             -- chipselect
			onchip_memory2_0_s1_write      : in  std_logic                     := 'X';             -- write
			onchip_memory2_0_s1_readdata   : out std_logic_vector(31 downto 0);                    -- readdata
			onchip_memory2_0_s1_writedata  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			onchip_memory2_0_s1_byteenable : in  std_logic_vector(3 downto 0)  := (others => 'X')  -- byteenable
		);
	end component obstacle;

	u0 : component obstacle
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                 clk.clk
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --               reset.reset_n
			onchip_memory2_0_s1_address    => CONNECTED_TO_onchip_memory2_0_s1_address,    -- onchip_memory2_0_s1.address
			onchip_memory2_0_s1_clken      => CONNECTED_TO_onchip_memory2_0_s1_clken,      --                    .clken
			onchip_memory2_0_s1_chipselect => CONNECTED_TO_onchip_memory2_0_s1_chipselect, --                    .chipselect
			onchip_memory2_0_s1_write      => CONNECTED_TO_onchip_memory2_0_s1_write,      --                    .write
			onchip_memory2_0_s1_readdata   => CONNECTED_TO_onchip_memory2_0_s1_readdata,   --                    .readdata
			onchip_memory2_0_s1_writedata  => CONNECTED_TO_onchip_memory2_0_s1_writedata,  --                    .writedata
			onchip_memory2_0_s1_byteenable => CONNECTED_TO_onchip_memory2_0_s1_byteenable  --                    .byteenable
		);

