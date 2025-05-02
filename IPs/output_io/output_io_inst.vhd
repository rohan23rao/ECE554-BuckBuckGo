	component output_io is
		port (
			clk_clk                      : in  std_logic                     := 'X';             -- clk
			reset_reset_n                : in  std_logic                     := 'X';             -- reset_n
			output_fifo_in_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			output_fifo_in_write         : in  std_logic                     := 'X';             -- write
			output_fifo_in_waitrequest   : out std_logic;                                        -- waitrequest
			output_fifo_in_csr_address   : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			output_fifo_in_csr_read      : in  std_logic                     := 'X';             -- read
			output_fifo_in_csr_writedata : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			output_fifo_in_csr_write     : in  std_logic                     := 'X';             -- write
			output_fifo_in_csr_readdata  : out std_logic_vector(31 downto 0)                     -- readdata
		);
	end component output_io;

	u0 : component output_io
		port map (
			clk_clk                      => CONNECTED_TO_clk_clk,                      --                clk.clk
			reset_reset_n                => CONNECTED_TO_reset_reset_n,                --              reset.reset_n
			output_fifo_in_writedata     => CONNECTED_TO_output_fifo_in_writedata,     --     output_fifo_in.writedata
			output_fifo_in_write         => CONNECTED_TO_output_fifo_in_write,         --                   .write
			output_fifo_in_waitrequest   => CONNECTED_TO_output_fifo_in_waitrequest,   --                   .waitrequest
			output_fifo_in_csr_address   => CONNECTED_TO_output_fifo_in_csr_address,   -- output_fifo_in_csr.address
			output_fifo_in_csr_read      => CONNECTED_TO_output_fifo_in_csr_read,      --                   .read
			output_fifo_in_csr_writedata => CONNECTED_TO_output_fifo_in_csr_writedata, --                   .writedata
			output_fifo_in_csr_write     => CONNECTED_TO_output_fifo_in_csr_write,     --                   .write
			output_fifo_in_csr_readdata  => CONNECTED_TO_output_fifo_in_csr_readdata   --                   .readdata
		);

