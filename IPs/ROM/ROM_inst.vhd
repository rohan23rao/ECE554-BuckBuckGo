	component ROM is
		port (
			clk_rom_clk           : in  std_logic                     := 'X';             -- clk
			rom_slave_address     : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- address
			rom_slave_debugaccess : in  std_logic                     := 'X';             -- debugaccess
			rom_slave_clken       : in  std_logic                     := 'X';             -- clken
			rom_slave_chipselect  : in  std_logic                     := 'X';             -- chipselect
			rom_slave_write       : in  std_logic                     := 'X';             -- write
			rom_slave_readdata    : out std_logic_vector(31 downto 0);                    -- readdata
			rom_slave_writedata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			rom_slave_byteenable  : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			rst_rom_reset         : in  std_logic                     := 'X'              -- reset
		);
	end component ROM;

	u0 : component ROM
		port map (
			clk_rom_clk           => CONNECTED_TO_clk_rom_clk,           --   clk_rom.clk
			rom_slave_address     => CONNECTED_TO_rom_slave_address,     -- rom_slave.address
			rom_slave_debugaccess => CONNECTED_TO_rom_slave_debugaccess, --          .debugaccess
			rom_slave_clken       => CONNECTED_TO_rom_slave_clken,       --          .clken
			rom_slave_chipselect  => CONNECTED_TO_rom_slave_chipselect,  --          .chipselect
			rom_slave_write       => CONNECTED_TO_rom_slave_write,       --          .write
			rom_slave_readdata    => CONNECTED_TO_rom_slave_readdata,    --          .readdata
			rom_slave_writedata   => CONNECTED_TO_rom_slave_writedata,   --          .writedata
			rom_slave_byteenable  => CONNECTED_TO_rom_slave_byteenable,  --          .byteenable
			rst_rom_reset         => CONNECTED_TO_rst_rom_reset          --   rst_rom.reset
		);

