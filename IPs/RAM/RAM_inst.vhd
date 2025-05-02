	component RAM is
		port (
			clk_ram_clk          : in  std_logic                     := 'X';             -- clk
			ram_slave_address    : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- address
			ram_slave_clken      : in  std_logic                     := 'X';             -- clken
			ram_slave_chipselect : in  std_logic                     := 'X';             -- chipselect
			ram_slave_write      : in  std_logic                     := 'X';             -- write
			ram_slave_readdata   : out std_logic_vector(31 downto 0);                    -- readdata
			ram_slave_writedata  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			ram_slave_byteenable : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			rst_ram_reset        : in  std_logic                     := 'X';             -- reset
			rst_ram_reset_req    : in  std_logic                     := 'X'              -- reset_req
		);
	end component RAM;

	u0 : component RAM
		port map (
			clk_ram_clk          => CONNECTED_TO_clk_ram_clk,          --   clk_ram.clk
			ram_slave_address    => CONNECTED_TO_ram_slave_address,    -- ram_slave.address
			ram_slave_clken      => CONNECTED_TO_ram_slave_clken,      --          .clken
			ram_slave_chipselect => CONNECTED_TO_ram_slave_chipselect, --          .chipselect
			ram_slave_write      => CONNECTED_TO_ram_slave_write,      --          .write
			ram_slave_readdata   => CONNECTED_TO_ram_slave_readdata,   --          .readdata
			ram_slave_writedata  => CONNECTED_TO_ram_slave_writedata,  --          .writedata
			ram_slave_byteenable => CONNECTED_TO_ram_slave_byteenable, --          .byteenable
			rst_ram_reset        => CONNECTED_TO_rst_ram_reset,        --   rst_ram.reset
			rst_ram_reset_req    => CONNECTED_TO_rst_ram_reset_req     --          .reset_req
		);

