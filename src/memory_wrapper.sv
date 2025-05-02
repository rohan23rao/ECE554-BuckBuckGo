`timescale 1ns / 1ps

module memory_wrapper (
    input  wire         clk,
    input  wire         resetn,
	input  wire         mem_sel,
    input  wire [31:0]  mem_addr,      // CPU-accessed byte address
    input  wire [31:0]  mem_wdata,     // 32-bit write data
    input  wire [3:0]   mem_wstrb,     // Byte enables for writes
    input  wire         mem_read,      // Read enable
    input  wire         mem_write,     // Write enable
    output wire [31:0]  mem_rdata,     // Read data (32 bits)
    output wire         mem_waitrequest, // Wait if target memory isn’t ready
	output wire         sdram_selected,
	output wire         sdram_readdatavalid,
	
	input  wire         vpu_active,
	input  wire 		dm_v_write,
    input  wire [31:0]  data_addr0,
    input  wire [31:0]	data_addr1,
    input  wire [31:0]	data_addr2,
    input  wire [31:0]	data_addr3,
    input  wire [31:0]	v_store_data_0,
    input  wire [31:0]	v_store_data_1,
    input  wire [31:0]	v_store_data_2,
    input  wire [31:0]	v_store_data_3,
    output wire [31:0]	v_load_data_0,
    output wire [31:0]	v_load_data_1,
    output wire [31:0]	v_load_data_2,
    output wire [31:0]	v_load_data_3,
	
	output  wire       clk143hz_shift50_1_clk,
	output wire        sdram_pll_reset_source_reset,      // sdram_pll_reset_source.reset
	output wire [12:0] sdram_wire_addr,                   //             sdram_wire.addr
	output wire [1:0]  sdram_wire_ba,                     //                       .ba
	output wire        sdram_wire_cas_n,                  //                       .cas_n
	output wire        sdram_wire_cke,                    //                       .cke
	output wire        sdram_wire_cs_n,                   //                       .cs_n
	inout  wire [15:0] sdram_wire_dq,                     //                       .dq
	output wire [1:0]  sdram_wire_dqm,                    //                       .dqm
	output wire        sdram_wire_ras_n,                  //                       .ras_n
	output wire        sdram_wire_we_n  
);

    //-------------------------------------------------------------------------
    // Address Regions
    //-------------------------------------------------------------------------
    // Define SDRAM start address. Any address >= SDRAM_BASE is for SDRAM.
    localparam SDRAM_BASE = 32'hC0000000;
    
    // Select path based on address:
    wire sdram_sel = (mem_addr >= SDRAM_BASE) && mem_sel;
    wire ram_sel   = (~sdram_sel && mem_sel) || (~sdram_sel && vpu_active);
	
	assign sdram_selected = sdram_sel;

    //-------------------------------------------------------------------------
    // On-Chip RAM (4-Bank) Mapping
    //-------------------------------------------------------------------------
    // We assume our on-chip memory region is 16 KB in total.
    // A 16 KB region provides 16K/4 = 4096 32-bit words.
    // Interleaving 4 banks means each bank stores 4096/4 = 1024 words (4 KB per bank).
    //
    // With byte addressing, a 32-bit word is at an address that is a multiple of 4.
    // We use:
    //   - Bits [3:2] of mem_addr to choose among banks 0-3.
    //   - Bits [11:2] as the word address within the unified region.
    //
    // For each bank, the local address is the overall word address divided by 4.
    // For example, let A = mem_addr[31:2] (the 30-bit word address).
    // Then bank_sel = A[1:0] = mem_addr[3:2], and the address within each bank is A[11:2] = mem_addr[11:2].
    
    wire [1:0] bank_sel = mem_addr[3:2];
    // For a 16 KB on-chip region, valid word addresses are 0 to 4095;
    // since each bank is 4 KB (1024 words), we use bits [11:2] (10 bits) as the bank-local address.
    wire [9:0] bank_addr = mem_addr[11:2]; 

    // Instantiate four independent 4 KB RAM modules.
    // Each module is a 32-bit wide memory with 1024 words.
    // They are enabled only when the overall address targets the RAM region,
    // and the bank_sel bits match the particular bank.
    
    // Chip-select signals for each bank:
    wire cs0 = ram_sel && ( (bank_sel == 2'b00) || vpu_active);
    wire cs1 = ram_sel && ( (bank_sel == 2'b01) || vpu_active);
    wire cs2 = ram_sel && ( (bank_sel == 2'b10) || vpu_active);
    wire cs3 = ram_sel && ( (bank_sel == 2'b11) || vpu_active);

    // Write enable signals for each bank:
    wire wr0 = ( cs0 && mem_write && (|mem_wstrb) ) || (vpu_active && dm_v_write);
    wire wr1 = ( cs1 && mem_write && (|mem_wstrb) ) || (vpu_active && dm_v_write);
    wire wr2 = ( cs2 && mem_write && (|mem_wstrb) ) || (vpu_active && dm_v_write);
    wire wr3 = ( cs3 && mem_write && (|mem_wstrb) ) || (vpu_active && dm_v_write);

    // The address input for each RAM instance is the same local address.
    // (Assuming the RAM module uses word addressing.)
    wire [9:0] local_addr = bank_addr;

    wire [31:0] ram0_rdata, ram1_rdata, ram2_rdata, ram3_rdata;

    // RAM instance 0 (Bank 0)
    RAM ram_inst0 (
        .clk_ram_clk      (clk),
        .ram_slave_address(vpu_active ? data_addr0 : local_addr),
        .ram_slave_clken  (1'b1),
        .ram_slave_chipselect(cs0),
        .ram_slave_write  (wr0),
        .ram_slave_writedata(vpu_active ? v_store_data_0 : mem_wdata),
        .ram_slave_byteenable(vpu_active ? 4'b1111 : mem_wstrb),
        .ram_slave_readdata(ram0_rdata),
        .rst_ram_reset    (~resetn),
        .rst_ram_reset_req(1'b0)
    );

    // RAM instance 1 (Bank 1)
    RAM ram_inst1 (
        .clk_ram_clk      (clk),
        .ram_slave_address(vpu_active ? data_addr1 : local_addr),
        .ram_slave_clken  (1'b1),
        .ram_slave_chipselect(cs1),
        .ram_slave_write  (wr1),
        .ram_slave_writedata(vpu_active ? v_store_data_1 : mem_wdata),
        .ram_slave_byteenable(vpu_active ? 4'b1111 : mem_wstrb),
        .ram_slave_readdata(ram1_rdata),
        .rst_ram_reset    (~resetn),
        .rst_ram_reset_req(1'b0)
    );

    // RAM instance 2 (Bank 2)
    RAM ram_inst2 (
        .clk_ram_clk      (clk),
        .ram_slave_address(vpu_active ? data_addr2 : local_addr),
        .ram_slave_clken  (1'b1),
        .ram_slave_chipselect(cs2),
        .ram_slave_write  (wr2),
        .ram_slave_writedata(vpu_active ? v_store_data_2 :mem_wdata),
        .ram_slave_byteenable(vpu_active ? 4'b1111 : mem_wstrb),
        .ram_slave_readdata(ram2_rdata),
        .rst_ram_reset    (~resetn),
        .rst_ram_reset_req(1'b0)
    );

    // RAM instance 3 (Bank 3)
    RAM ram_inst3 (
        .clk_ram_clk      (clk),
        .ram_slave_address(vpu_active ? data_addr3 : local_addr),
        .ram_slave_clken  (1'b1),
        .ram_slave_chipselect(cs3),
        .ram_slave_write  (wr3),
        .ram_slave_writedata(vpu_active ? v_store_data_3 :mem_wdata),
        .ram_slave_byteenable(vpu_active ? 4'b1111 : mem_wstrb),
        .ram_slave_readdata(ram3_rdata),
        .rst_ram_reset    (~resetn),
        .rst_ram_reset_req(1'b0)
    );

    // Multiplexer for RAM read data: choose the bank based on bank_sel.
    reg [31:0] ram_rdata;
    always @(*) begin
        case (bank_sel)
            2'b00: ram_rdata = ram0_rdata;
            2'b01: ram_rdata = ram1_rdata;
            2'b10: ram_rdata = ram2_rdata;
            2'b11: ram_rdata = ram3_rdata;
            default: ram_rdata = 32'h0;
        endcase
    end
	
	assign v_load_data_0 = ram0_rdata;
	assign v_load_data_1 = ram1_rdata;
	assign v_load_data_2 = ram2_rdata;
	assign v_load_data_3 = ram3_rdata;

    //-------------------------------------------------------------------------
    // SDRAM Interface Instance
    //-------------------------------------------------------------------------
    // The SDRAM is mapped into addresses >= SDRAM_BASE.
    // Because the SDRAM interface is 16-bit wide and is used for weight storage, 
    // we assume it’s read-only after initialization.
    // For SDRAM, subtract SDRAM_BASE to get the local SDRAM address.
    wire [31:0] sdram_addr;
    assign sdram_addr = mem_addr - SDRAM_BASE;
    wire [31:0] sdram_data_in = mem_wdata;  // For completeness
    wire sdram_wr = sdram_sel && mem_write && (|mem_wstrb);
    wire sdram_rd = sdram_sel && mem_read;

    wire [31:0] sdram_data_out;
    //wire sdram_readdatavalid;
    wire sdram_waitrequest;

    memory sdram_interface (
        .clk_clk                            (clk),
        .reset_reset_n                      (resetn),
		.sdram_pll_reset_source_reset(sdram_pll_reset_source_reset),
        .clk143hz_shift50_1_clk(clk143hz_shift50_1_clk),
		
        .sdram_wire_addr(sdram_wire_addr),
        .sdram_wire_ba(sdram_wire_ba),
        .sdram_wire_cas_n(sdram_wire_cas_n),
        .sdram_wire_cke(sdram_wire_cke),
        .sdram_wire_cs_n(sdram_wire_cs_n),
        .sdram_wire_dq(sdram_wire_dq),
        .sdram_wire_dqm(sdram_wire_dqm),
        .sdram_wire_ras_n(sdram_wire_ras_n),
        .sdram_wire_we_n(sdram_wire_we_n),
		

        // Interface to our wrapper:
        .sdram_wrapper_wires_address        (sdram_addr),
        .sdram_wrapper_wires_writedata      (sdram_data_in),
        .sdram_wrapper_wires_write          (sdram_wr),
        .sdram_wrapper_wires_read           (sdram_rd),
        .sdram_wrapper_wires_readdata       (sdram_data_out),
        .sdram_wrapper_wires_readdatavalid  (sdram_readdatavalid),
        .sdram_wrapper_wires_waitrequest    (sdram_waitrequest)
    );

    //-------------------------------------------------------------------------
    // Unified Output Multiplexer
    //-------------------------------------------------------------------------
    // If the access is in the SDRAM region, forward SDRAM signals.
    // Otherwise, use the on-chip RAM read data.
    assign mem_rdata = sdram_sel ? sdram_data_out : ram_rdata;
    assign mem_waitrequest = sdram_sel ? sdram_waitrequest : 1'b0;

endmodule
