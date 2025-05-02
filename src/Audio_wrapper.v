module input_audio(
    //////////// Audio //////////
    input                AUD_ADCDAT,
    inout                AUD_ADCLRCK,
    inout                AUD_BCLK,
    output               AUD_DACDAT,
    inout                AUD_DACLRCK,
    output               AUD_XCK,

    input                rst_n,
    input                clk,
    
    // CPU interface
    input                read_req,
    output               read_valid,
    output      [31:0]   read_data,

    //////////// I2C for Audio and Video-In //////////
    output               FPGA_I2C_SCLK,
    inout                FPGA_I2C_SDAT,

    //////////// KEY //////////
    input       [3:0]    KEY,

    //////////// LED //////////
    output      [9:0]    LEDR
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

// Audio system wires
// The streaming-sink (data you'd feed into DAC)
wire [15:0]  right_sink_data;
wire         right_sink_valid;
wire         right_sink_ready;
wire [15:0]  left_sink_data;
wire         left_sink_ready;

// AVConfig (I2C) interface
wire  [1:0]  cfg_addr;
wire  [3:0]  cfg_byteenable;
wire         cfg_read;
wire         cfg_write;
wire [31:0]  cfg_writedata;
wire [31:0]  cfg_readdata;
wire         cfg_waitrequest;

// FIFO interface
wire         fifo_out_ready;
wire [15:0]  fifo_out_data;
wire         fifo_out_valid;

// Final FIFO interface
wire [15:0]  final_fifo_out_data;
wire         final_fifo_out_valid;
wire         final_fifo_out_ready;

// Debug signals
wire         fifo_almost_empty;
wire         fifo_almost_full;

wire         final_fifo_almost_empty;
wire         final_fifo_almost_full;

// Control signal for final FIFO
wire         enable_final_fifo;

// KEY[1] synchronization for debouncing
reg  [1:0]   key1_sync;
reg  [1:0]   key2_sync;

wire      enable_playback;

//=======================================================
//  Button synchronization and control logic
//=======================================================

// Synchronize KEY[1] to avoid metastability
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key1_sync <= 2'b11; // Default state (not pressed)
		//key2_sync <= 2'b11; 
    end else begin
        key1_sync <= {key1_sync[0], KEY[1]};
		//key2_sync <= {key2_sync[0], KEY[2]};
    end
end

// Generate the enable signal for the final FIFO
// KEY[1] is active low, so we enable when KEY[1] is 0 (pressed)
assign enable_final_fifo = (key1_sync[1] == 1'b0);
//assign enable_playback = (key2_sync[1] == 1'b0);
//=======================================================
//  Structural coding
//=======================================================

audio_system u_audio_system (
    // Right-channel streaming interface (loopback)
   /* .audio_0_avalon_right_channel_sink_data    (right_sink_data),
    .audio_0_avalon_right_channel_sink_valid   (right_sink_valid),
    .audio_0_avalon_right_channel_sink_ready   (right_sink_ready),
    .audio_0_avalon_right_channel_source_ready (right_sink_ready),
    .audio_0_avalon_right_channel_source_data  (right_sink_data),
    .audio_0_avalon_right_channel_source_valid (right_sink_valid), */

    // External I/O to the WM8731 audio codec
    .audio_0_external_interface_ADCDAT   (AUD_ADCDAT),
    .audio_0_external_interface_ADCLRCK  (AUD_ADCLRCK),
    .audio_0_external_interface_BCLK     (AUD_BCLK),
    .audio_0_external_interface_DACDAT   (AUD_DACDAT),
    .audio_0_external_interface_DACLRCK  (AUD_DACLRCK),

    // I2C config interface
    .audio_and_video_config_0_avalon_av_config_slave_address     (cfg_addr),
    .audio_and_video_config_0_avalon_av_config_slave_byteenable  (cfg_byteenable),
    .audio_and_video_config_0_avalon_av_config_slave_read        (cfg_read),
    .audio_and_video_config_0_avalon_av_config_slave_write       (cfg_write),
    .audio_and_video_config_0_avalon_av_config_slave_writedata   (cfg_writedata),
    .audio_and_video_config_0_avalon_av_config_slave_readdata    (cfg_readdata),
    .audio_and_video_config_0_avalon_av_config_slave_waitrequest (cfg_waitrequest),
    .audio_and_video_config_0_external_interface_SDAT            (FPGA_I2C_SDAT),
    .audio_and_video_config_0_external_interface_SCLK            (FPGA_I2C_SCLK),

    // Generated audio clock
    .audio_pll_0_audio_clk_clk (AUD_XCK),

    // System clock & reset
    .clk_clk       (clk),
    .reset_reset_n (rst_n),
    
    // FIFO status signals
    .audio_sc_fifo_almost_empty_data (fifo_almost_empty),
    .audio_sc_fifo_almost_full_data  (fifo_almost_full),
    
    // Left channel interface
    //.audio_0_avalon_left_channel_sink_data  (final_fifo_out_data),
    //.audio_0_avalon_left_channel_sink_valid (enable_playback && final_fifo_out_valid),  // Not used for input
    //.audio_0_avalon_left_channel_sink_ready (left_sink_ready),
    
    // First FIFO interface - always drain this FIFO
    .audio_sc_fifo_out_data   (fifo_out_data),
    .audio_sc_fifo_out_valid  (fifo_out_valid),
    .audio_sc_fifo_out_ready  (fifo_out_ready),
    
    // Final FIFO interface - only accept values when KEY[1] is pressed
    .audio_final_fifo_in_data  (fifo_out_data),
    .audio_final_fifo_in_valid (fifo_out_valid && enable_final_fifo),  // Only valid when enabled
    .audio_final_fifo_in_ready (final_fifo_out_ready),
	
	//playback
	//.audio_playback_fifo_in_data(final_fifo_out_data),                                 //                          audio_playback_fifo_in.data
	//.audio_playback_fifo_in_valid(enable_playback && final_fifo_out_valid),                                //                                                .valid
	//.audio_playback_fifo_in_ready(left_sink_ready),  
    
    // Final FIFO status and output
    .audio_final_fifo_almost_empty_data (final_fifo_almost_empty),
    .audio_final_fifo_almost_full_data  (final_fifo_almost_full),
    .audio_final_fifo_out_data          (final_fifo_out_data),
    .audio_final_fifo_out_valid         (final_fifo_out_valid),
    .audio_final_fifo_out_ready         (fifo_out_ready)  
);

// Always drain the first FIFO regardless of whether we're storing in final FIFO
assign fifo_out_ready = 1'b1;

// Simple state machine for testing
reg [31:0] output_reg;
reg        output_valid;

// Always drain the final FIFO except when providing data to CPU
assign final_fifo_out_ready = !output_valid;

// Simple read process
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        output_reg <= 32'd0;
        output_valid <= 1'b0;
    end
    else begin
        // Clear valid when CPU has read the data
        if (read_req && output_valid) begin
            output_valid <= 1'b0;
        end
        
        // If FIFO has data and we're not already holding valid data,
        // capture the next sample
        if (final_fifo_out_valid && !output_valid) begin
            output_reg <= {16'h0000, final_fifo_out_data};
            output_valid <= 1'b1;
        end
    end
end

// CPU interface
assign read_valid = output_valid;
assign read_data = output_reg;

// Debug LEDs
assign LEDR[0] = final_fifo_out_valid;
assign LEDR[1] = output_valid;
assign LEDR[2] = read_req;
assign LEDR[3] = enable_final_fifo;  // Show the state of the enable signal
assign LEDR[9:4] = output_reg[5:0];

endmodule