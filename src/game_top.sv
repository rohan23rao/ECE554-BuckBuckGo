`timescale 1ns / 1ps

module game_top(
    input wire clk,
    input wire rst_n,

    input wire [9:0] char_x,
    input wire [9:0] char_y,
    input wire [9:0] obstacle_x,
    input wire [9:0] obstacle_height_bottom,  // from ground upward
    input wire [9:0] obstacle_height_top,     // from top downward
    input wire [15:0] score,
    input wire [0:0] game_status,              // 0: playing, 1: game over
    input wire [3:0] KEY,

    output wire [9:0] VGA_R,
    output wire [9:0] VGA_G,
    output wire [9:0] VGA_B,
    output wire VGA_H_SYNC,
    output wire VGA_V_SYNC,
    output wire VGA_SYNC,
    output wire VGA_BLANK
);

// Internal wires
wire [9:0] pixel_x, pixel_y;
wire oRequest;
wire frame_tick = oRequest && (pixel_x == 10'd0) && (pixel_y == 10'd0);
reg [9:0] iRed, iGreen, iBlue;

wire [9:0] char_size = 32;
wire [9:0] obstacle_width = 42;
wire [9:0] ground_y = 448;

// Font scaling
localparam FONT_SCALE = 2;
// ----------------------------------------------------------------------------
// BACKGROUND
// ----------------------------------------------------------------------------
localparam IMG_W = 640;

wire       idx_en;
wire [18:0] idx_addr = pixel_y*IMG_W + pixel_x;  // 18 bits to cover 163200


  // 1) Image data ROM: data_mem_1 → 8-bit [0..1023]
  wire [7:0] pixel_idx;
  background_data u_image_data2 (
      .onchip_memory2_0_clk1_clk       (clk),
      .onchip_memory2_0_reset1_reset   (~rst_n),
      .onchip_memory2_0_reset1_reset_req(1'b0),
      .onchip_memory2_0_s1_address     (idx_addr),  // 10-bit addr
      .onchip_memory2_0_s1_debugaccess (1'b0),
      .onchip_memory2_0_s1_clken       (1'b1),
      .onchip_memory2_0_s1_chipselect  (1'b1),
      .onchip_memory2_0_s1_write       (1'b0),
      .onchip_memory2_0_s1_readdata    (pixel_idx),
      .onchip_memory2_0_s1_writedata   (8'b0)
  );

  // 2) Palette ROM: data_mem_2 → 32-bit [0..255]
  //    wrapper’s address port is 6 bits wide, so trim index
  wire [31:0] bg_pixel;
  background_index u_palette_data2 (
      .onchip_memory2_0_clk1_clk       (clk),
      .onchip_memory2_0_reset1_reset   (~rst_n),
      .onchip_memory2_0_reset1_reset_req(1'b0),
      .onchip_memory2_0_s1_address     (pixel_idx[5:0]),  // 10-bit addr
      .onchip_memory2_0_s1_debugaccess (1'b0),
      .onchip_memory2_0_s1_clken       (1'b1),
      .onchip_memory2_0_s1_chipselect  (1'b1),
      .onchip_memory2_0_s1_write       (1'b0),
      .onchip_memory2_0_s1_readdata    (bg_pixel),
      .onchip_memory2_0_s1_writedata   (8'b0)
  );

// STACKING LOGIC 
localparam PIPE_W   = 42;
localparam BODY_H   = 10;
localparam CAP_W    = 50;
localparam CAP_H    = 27;

localparam integer FPS          = 60;
localparam integer WAIT_FRAMES  = 3*FPS;

reg [8:0]  frame_wait_cnt = 0;
reg        freeze_game    = 1'b0;


wire [5:0]  num_tiles =
        (obstacle_height_bottom + (BODY_H-1)) / BODY_H;

wire [9:0]  round_h   = num_tiles * BODY_H;
wire        pipe_x_hit = (pixel_x >= obstacle_x) &&
                         (pixel_x <  obstacle_x + PIPE_W);

wire [6:0]  body_u     = pixel_x - obstacle_x;            // 0-19


wire [9:0]  y_local    = ground_y - 1 - pixel_y;          // grows upward
wire [4:0]  row_in_tile= y_local % BODY_H;                // 0-9  (wraps)
wire        pipe_y_hit = (y_local < round_h);             // inside pipe?



wire [9:0]  body_addr  = row_in_tile * PIPE_W + body_u;


// CAP LOGIC
localparam CAP_X_OFFS  = 4;   // =15 px each side


wire [9:0] cap_x0 = obstacle_x - CAP_X_OFFS;
wire [9:0] cap_x1 = cap_x0 + CAP_W;

// vertical extent for each cap
wire [9:0] cap_bot_y0 = ground_y - obstacle_height_bottom - CAP_H;  // start
wire [9:0] cap_bot_y1 = ground_y - obstacle_height_bottom;          // end

wire [9:0] cap_top_y0 = obstacle_height_top;           // start
wire [9:0] cap_top_y1 = obstacle_height_top + CAP_H;   // end


wire cap_bot_en = (pixel_x >= cap_x0) && (pixel_x < cap_x1) &&
                  (pixel_y >= cap_bot_y0) && (pixel_y < cap_bot_y1);

wire cap_top_en = (pixel_x >= cap_x0) && (pixel_x < cap_x1) &&
                  (pixel_y >= cap_top_y0) && (pixel_y < cap_top_y1);

wire cap_hit = cap_bot_en | cap_top_en;


wire [5:0] cap_u = pixel_x - cap_x0;                       // 0-49
wire [4:0] cap_v = cap_bot_en ? (pixel_y - cap_bot_y0)     // 0-26
                              : (pixel_y - cap_top_y0);


wire [10:0] cap_addr = cap_v * CAP_W + cap_u;

  wire [31:0] pillar_pixel;
  // Obstacle ROM
  wire [31:0] cap_rgb;


  obstacle Obstacle_data(
		.clk_clk(clk),                        //                 clk.clk
		.onchip_memory2_0_s1_address(body_addr),    // onchip_memory2_0_s1.address
		.onchip_memory2_0_s1_clken(1'b1),      //                    .clken
		.onchip_memory2_0_s1_chipselect(1'b1), //                    .chipselect
		.onchip_memory2_0_s1_write(1'b0),      //                    .write
		.onchip_memory2_0_s1_readdata(pillar_pixel),   //                    .readdata
		.onchip_memory2_0_s1_writedata(8'b0),  //                    .writedata
		.onchip_memory2_0_s1_byteenable(4'b1111), //                    .byteenable
		.reset_reset_n(rst_n)                   //               reset.reset_n
	);


    obstacle_top obstacle_top_data (
      .onchip_memory2_0_clk1_clk       (clk),
      .onchip_memory2_0_reset1_reset   (~rst_n),
      .onchip_memory2_0_reset1_reset_req(1'b0),
      .onchip_memory2_0_s1_address     (cap_addr),  // 10-bit addr
      .onchip_memory2_0_s1_debugaccess (1'b0),
      .onchip_memory2_0_s1_clken       (1'b1),
      .onchip_memory2_0_s1_chipselect  (1'b1),
      .onchip_memory2_0_s1_write       (1'b0),
      .onchip_memory2_0_s1_readdata    (cap_rgb),
      .onchip_memory2_0_s1_writedata   (8'b0)
  );
    //-------------------------------------------------------------------------
  // Sprite address calculation
  //-------------------------------------------------------------------------


wire [4:0]  sprite_u    = pixel_x - char_x;  
wire [4:0]  sprite_v    = pixel_y - char_y;  
wire [15:0] sprite_addr = sprite_v *32 + sprite_u;

wire [4:0]  cheese_sprite_u    = pixel_x - char_x;  
wire [4:0]  cheese_sprite_v    = pixel_y - char_y;  
wire [15:0] cheese_sprite_addr = cheese_sprite_v *32 + cheese_sprite_u;

  //-------------------------------------------------------------------------
  // Instantiate your MIF-based ROM wrappers
  //-------------------------------------------------------------------------

  // 1) Image data ROM: data_mem_1 → 8-bit [0..1023]
  wire [7:0] sprite_index;
  data_mem_1 u_image_data (
      .onchip_memory2_0_clk1_clk       (clk),
      .onchip_memory2_0_reset1_reset   (~rst_n),
      .onchip_memory2_0_reset1_reset_req(1'b0),
      .onchip_memory2_0_s1_address     (sprite_addr[9:0]),  // 10-bit addr
      .onchip_memory2_0_s1_debugaccess (1'b0),
      .onchip_memory2_0_s1_clken       (1'b1),
      .onchip_memory2_0_s1_chipselect  (1'b1),
      .onchip_memory2_0_s1_write       (1'b0),
      .onchip_memory2_0_s1_readdata    (sprite_index),
      .onchip_memory2_0_s1_writedata   (8'b0)
  );

  // 2) Palette ROM: data_mem_2 → 32-bit [0..255]
  //    wrapper’s address port is 6 bits wide, so trim index
  wire [31:0] palette_rgb;
  wire [5:0]  palette_addr = sprite_index[5:0];
  data_mem_2 u_palette_data (
      .palette_clk1_clk        (clk),
      .palette_reset1_reset    (~rst_n),
      .palette_reset1_reset_req(1'b0),
      .palette_s1_address      (palette_addr),
      .palette_s1_clken        (1'b1),
      .palette_s1_chipselect   (1'b1),
      .palette_s1_write        (1'b0),
      .palette_s1_readdata     (palette_rgb),
      .palette_s1_writedata    (32'b0),
      .palette_s1_byteenable   (4'b1111)
  );

    wire [8:0] mask_output;
    wire mask_sel;
    assign mask_sel = mask_output[0];
    data_mem_3 u_mask (
      .onchip_memory2_0_clk1_clk       (clk),
      .onchip_memory2_0_reset1_reset   (~rst_n),
      .onchip_memory2_0_reset1_reset_req(1'b0),
      .onchip_memory2_0_s1_address     (sprite_addr[9:0]),  // 10-bit addr
      .onchip_memory2_0_s1_debugaccess (1'b0),
      .onchip_memory2_0_s1_clken       (1'b1),
      .onchip_memory2_0_s1_chipselect  (1'b1),
      .onchip_memory2_0_s1_write       (1'b0),
      .onchip_memory2_0_s1_readdata    (mask_output),
      .onchip_memory2_0_s1_writedata   (8'b0)
  );

    wire cheese_sel;
    assign cheese_sel = (score > 5);
    wire [31:0] palette_cheese;
    wire [7:0] cheesehat_sprite_index;
    wire [7:0] mask_output_cheese;
    wire mask_sel_cheese;
    assign mask_sel_cheese = mask_output_cheese[0];


    cheesehat_sprite cheese_hat (
      	.clk_clk(clk),
    	.reset_reset_n(rst_n),
	    .onchip_memory2_0_s1_address(cheese_sprite_addr[9:0]),
	    .onchip_memory2_0_s1_debugaccess(1'b0),
	    .onchip_memory2_0_s1_clken(1'b1),
	    .onchip_memory2_0_s1_chipselect(1'b1),
	    .onchip_memory2_0_s1_write(1'b0),
	    .onchip_memory2_0_s1_readdata(cheesehat_sprite_index),
	    .onchip_memory2_0_s1_writedata(8'h00),
	    .onchip_memory2_1_s1_address(cheesehat_sprite_index[5:0]),
	    .onchip_memory2_1_s1_debugaccess(1'b0),
	    .onchip_memory2_1_s1_clken(1'b1),
	    .onchip_memory2_1_s1_chipselect(1'b1),
	    .onchip_memory2_1_s1_write(1'b0),
	    .onchip_memory2_1_s1_readdata(palette_cheese),
	    .onchip_memory2_1_s1_writedata(32'h0000),
	    .onchip_memory2_1_s1_byteenable(4'b1111),
	    .onchip_memory2_2_s1_address(cheese_sprite_addr[9:0]),
	    .onchip_memory2_2_s1_debugaccess(1'b0),
	    .onchip_memory2_2_s1_clken(1'b1),
	    .onchip_memory2_2_s1_chipselect(1'b1),
	    .onchip_memory2_2_s1_write(1'b0),
	    .onchip_memory2_2_s1_readdata(mask_output_cheese),
	    .onchip_memory2_2_s1_writedata(8'h00)
  );

// ----------------------------------------------------------------------------
// BACKGROUND
// ----------------------------------------------------------------------------
reg  [1:0]   key1_sync;
wire key3_press;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key1_sync <= 2'b11; // Default state (not pressed)
    end else begin
        key1_sync <= {key1_sync[0], KEY[3]};
    end
end
assign key3_press = (key1_sync[1] == 1'b0);


// HIGH SCORE
logic [15:0] high_score;
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        high_score <= 0;
    end
    else if ((score > high_score)) begin
        high_score <= score;
    end
    else begin
        high_score <= high_score;
    end
end
// HIGH SCORE END

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        freeze_game <= 1'b0;
    end
    else if (game_status == 1'b1) begin
        freeze_game <= 1'b1;
    end
    else if (freeze_game && key3_press) begin
        freeze_game <= 1'b0;
    end
end



// Instantiate VGA controller
VGA_Controller vga_inst (
    .iRed(iRed),
    .iGreen(iGreen),
    .iBlue(iBlue),
    .oRequest(oRequest),
    .oVGA_R(VGA_R),
    .oVGA_G(VGA_G),
    .oVGA_B(VGA_B),
    .oVGA_H_SYNC(VGA_H_SYNC),
    .oVGA_V_SYNC(VGA_V_SYNC),
    .oVGA_SYNC(VGA_SYNC),
    .oVGA_BLANK(VGA_BLANK),
    .iCLK(clk),
    .iRST_N(rst_n),
    .iZOOM_MODE_SW(1'b0),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
);

// Font bitmap lookup
function [34:0] font_bitmap;
    input [7:0] ascii;
    begin
        case (ascii)
            "0": font_bitmap = 35'b01110_10001_10011_10101_11001_10001_01110;
            "1": font_bitmap = 35'b00100_01100_00100_00100_00100_00100_01110;
            "2": font_bitmap = 35'b01110_10001_00001_00010_00100_01000_11111;
            "3": font_bitmap = 35'b11111_00010_00100_00010_00001_10001_01110;
            "4": font_bitmap = 35'b00010_00110_01010_10010_11111_00010_00010;
            "5": font_bitmap = 35'b11111_10000_11110_00001_00001_10001_01110;
            "6": font_bitmap = 35'b00110_01000_10000_11110_10001_10001_01110;
            "7": font_bitmap = 35'b11111_00001_00010_00100_01000_01000_01000;
            "8": font_bitmap = 35'b01110_10001_10001_01110_10001_10001_01110;
            "9": font_bitmap = 35'b01110_10001_10001_01111_00001_00010_01100;
            "S": font_bitmap = 35'b01111_10000_10000_01110_00001_00001_11110;
            "C": font_bitmap = 35'b00111_01000_10000_10000_10000_01000_00111;
            "O": font_bitmap = 35'b01110_10001_10001_10001_10001_10001_01110;
            "R": font_bitmap = 35'b11110_10001_10001_11110_10100_10010_10001;
            "E": font_bitmap = 35'b11111_10000_10000_11110_10000_10000_11111;
            "G": font_bitmap = 35'b01110_10001_10000_10111_10001_10001_01110;
            "A": font_bitmap = 35'b01110_10001_10001_11111_10001_10001_10001;
            "M": font_bitmap = 35'b10001_11011_10101_10101_10001_10001_10001;
            "V": font_bitmap = 35'b10001_10001_10001_10001_10001_01010_00100;
            ":": font_bitmap = 35'b00000_00100_00000_00000_00100_00000_00000;
            "H": font_bitmap = 35'b10001_10001_10001_11111_10001_10001_10001;
            "I": font_bitmap = 35'b11111_00100_00100_00100_00100_00100_11111;
            default: font_bitmap = 35'd0;
        endcase
    end
endfunction

reg [34:0] current_bitmap;
integer char_idx;
integer font_x, font_y;

// Main drawing logic
always @(posedge clk) begin
    if (oRequest) begin
        //iRed   <= 10'h000;
        //iGreen <= 10'h000;
        //iBlue  <= 10'h3FF;  // Default background: sky blue
		iRed <= bg_pixel[23:16];
		iGreen <= bg_pixel[15:8];
		iBlue <= bg_pixel[7:0];

        if (freeze_game) begin
            iRed <= bg_pixel[23:16];
		    iGreen <= bg_pixel[15:8];
		    iBlue <= bg_pixel[7:0];

            if ((pixel_y >= 20) && (pixel_y < (20 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 14; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (20 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (20 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (20 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 20) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("H");
                            1: current_bitmap = font_bitmap("I");
                            2: current_bitmap = font_bitmap("G");
                            3: current_bitmap = font_bitmap("H");
                            4: current_bitmap = font_bitmap(" ");
                            5: current_bitmap = font_bitmap("S");
                            6: current_bitmap = font_bitmap("C");
                            7: current_bitmap = font_bitmap("O");
                            8: current_bitmap = font_bitmap("R");
                            9: current_bitmap = font_bitmap("E");
                            10: current_bitmap = font_bitmap(":");
                            11: current_bitmap = font_bitmap(8'd48 + (high_score/100) % 10);
                            12: current_bitmap = font_bitmap(8'd48 + (high_score/10) % 10);
                            13: current_bitmap = font_bitmap(8'd48 + (high_score/1) % 10);
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h361;
                            iGreen <= 10'h30c;
                            iBlue <= 10'h00c;
                        end
                    end
                end
            end
            else if ((pixel_y >= 240) && (pixel_y < (240 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 9; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (320 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (320 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (320 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 240) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("G");
                            1: current_bitmap = font_bitmap("A");
                            2: current_bitmap = font_bitmap("M");
                            3: current_bitmap = font_bitmap("E");
                            4: current_bitmap = font_bitmap(" ");
                            5: current_bitmap = font_bitmap("O");
                            6: current_bitmap = font_bitmap("V");
                            7: current_bitmap = font_bitmap("E");
                            8: current_bitmap = font_bitmap("R");
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h3FF;
                            iGreen <= 10'h000;
                            iBlue <= 10'h000; // Red color
                        end
                    end
                end
            end
            else if ((pixel_y >= 50) && (pixel_y < (50 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 9; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (20 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (20 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (20 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 50) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("S");
                            1: current_bitmap = font_bitmap("C");
                            2: current_bitmap = font_bitmap("O");
                            3: current_bitmap = font_bitmap("R");
                            4: current_bitmap = font_bitmap("E");
                            5: current_bitmap = font_bitmap(":");
                            6: current_bitmap = font_bitmap(8'd48 + (score/100) % 10);
                            7: current_bitmap = font_bitmap(8'd48 + (score/10) % 10);
                            8: current_bitmap = font_bitmap(8'd48 + (score/1) % 10);
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h361;
                            iGreen <= 10'h30c;
                            iBlue <= 10'h00c;
                        end
                    end
                end
            end

        end else begin

        if (game_status == 1) begin
            // Game over message
            if ((pixel_y >= 200) && (pixel_y < (200 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 9; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (140 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (140 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (140 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 200) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("G");
                            1: current_bitmap = font_bitmap("A");
                            2: current_bitmap = font_bitmap("M");
                            3: current_bitmap = font_bitmap("E");
                            4: current_bitmap = font_bitmap(" ");
                            5: current_bitmap = font_bitmap("O");
                            6: current_bitmap = font_bitmap("V");
                            7: current_bitmap = font_bitmap("E");
                            8: current_bitmap = font_bitmap("R");
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h3FF;
                            iGreen <= 10'h000;
                            iBlue <= 10'h000; // Red color
                        end
                    end
                end
            end
        end
        else begin
            // Gameplay

            // Draw character
            if ((pixel_x >= char_x) && (pixel_x < char_x + char_size) &&
                (pixel_y >= char_y) && (pixel_y < char_y + char_size) && mask_sel && ~cheese_sel) begin
                iRed <= palette_rgb[23:16];
                iGreen <= palette_rgb[15:8];
                iBlue <= palette_rgb[7:0];
            end
            else if ((pixel_x >= char_x) && (pixel_x < char_x + char_size) &&
                (pixel_y >= char_y) && (pixel_y < char_y + char_size) && mask_sel_cheese && cheese_sel) begin
                iRed <= palette_cheese[23:16];
                iGreen <= palette_cheese[15:8];
                iBlue <= palette_cheese[7:0];
            end
            // Draw obstacle bottom
            else if ((pixel_x >= obstacle_x) && (pixel_x < obstacle_x + obstacle_width) &&
                     (pixel_y >= (ground_y - obstacle_height_bottom)) && (pixel_y < ground_y)) begin
                iRed <= pillar_pixel[23:16];
                iGreen <= pillar_pixel[15:8];
                iBlue <= pillar_pixel[7:0];
            end
            // Draw Cap (Obstacle Top Part)
            else if (cap_hit) begin
                iRed   <= cap_rgb[23:16];
                iGreen <= cap_rgb[15:8];
                iBlue  <= cap_rgb[7:0];
            end
            // Draw obstacle top
            else if ((pixel_x >= obstacle_x) && (pixel_x < obstacle_x + obstacle_width) &&
                     (pixel_y >= 0) && (pixel_y < obstacle_height_top)) begin
                iRed <= pillar_pixel[23:16];
                iGreen <= pillar_pixel[15:8];
                iBlue <= pillar_pixel[7:0];
            end

            // Draw score
            else if ((pixel_y >= 50) && (pixel_y < (50 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 9; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (20 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (20 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (20 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 50) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("S");
                            1: current_bitmap = font_bitmap("C");
                            2: current_bitmap = font_bitmap("O");
                            3: current_bitmap = font_bitmap("R");
                            4: current_bitmap = font_bitmap("E");
                            5: current_bitmap = font_bitmap(":");
                            6: current_bitmap = font_bitmap(8'd48 + (score/100) % 10);
                            7: current_bitmap = font_bitmap(8'd48 + (score/10) % 10);
                            8: current_bitmap = font_bitmap(8'd48 + (score/1) % 10);
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h361;
                            iGreen <= 10'h30c;
                            iBlue <= 10'h00c;
                        end
                    end
                end
            end
            else if ((pixel_y >= 20) && (pixel_y < (20 + 7*FONT_SCALE))) begin
                for (char_idx = 0; char_idx < 14; char_idx = char_idx + 1) begin
                    if ((pixel_x >= (20 + char_idx*(5*FONT_SCALE + 2))) &&
                        (pixel_x <  (20 + char_idx*(5*FONT_SCALE + 2) + 5*FONT_SCALE))) begin
                        
                        font_x = (pixel_x - (20 + char_idx*(5*FONT_SCALE + 2))) / FONT_SCALE;
                        font_y = (pixel_y - 20) / FONT_SCALE;

                        case (char_idx)
                            0: current_bitmap = font_bitmap("H");
                            1: current_bitmap = font_bitmap("I");
                            2: current_bitmap = font_bitmap("G");
                            3: current_bitmap = font_bitmap("H");
                            4: current_bitmap = font_bitmap(" ");
                            5: current_bitmap = font_bitmap("S");
                            6: current_bitmap = font_bitmap("C");
                            7: current_bitmap = font_bitmap("O");
                            8: current_bitmap = font_bitmap("R");
                            9: current_bitmap = font_bitmap("E");
                            10: current_bitmap = font_bitmap(":");
                            11: current_bitmap = font_bitmap(8'd48 + (high_score/100) % 10);
                            12: current_bitmap = font_bitmap(8'd48 + (high_score/10) % 10);
                            13: current_bitmap = font_bitmap(8'd48 + (high_score/1) % 10);
                            default: current_bitmap = 35'd0;
                        endcase

                        if (current_bitmap[(6 - font_y) * 5 + (4 - font_x)]) begin
                            iRed <= 10'h361;
                            iGreen <= 10'h30c;
                            iBlue <= 10'h00c;
                        end
                    end
                end
            end
        end
        end
    end
end

endmodule
