// --------------------------------------------------------------------
// VGA_Controller (Modified to output pixel_x, pixel_y)
// --------------------------------------------------------------------
module VGA_Controller(
    // Host Side
    input [9:0] iRed,
    input [9:0] iGreen,
    input [9:0] iBlue,
    output reg oRequest,

    // VGA Side
    output reg [9:0] oVGA_R,
    output reg [9:0] oVGA_G,
    output reg [9:0] oVGA_B,
    output reg oVGA_H_SYNC,
    output reg oVGA_V_SYNC,
    output reg oVGA_SYNC,
    output reg oVGA_BLANK,

    // Control Signal
    input iCLK,
    input iRST_N,
    input iZOOM_MODE_SW,

    // Added outputs
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y
);

// --------------------------------------------------------------------
// VGA Timing Parameters
parameter H_SYNC_CYC   = 96;
parameter H_SYNC_BACK  = 48;
parameter H_SYNC_ACT   = 640;
parameter H_SYNC_FRONT = 16;
parameter H_SYNC_TOTAL = 800;

parameter V_SYNC_CYC   = 2;
parameter V_SYNC_BACK  = 33;
parameter V_SYNC_ACT   = 480;
parameter V_SYNC_FRONT = 10;
parameter V_SYNC_TOTAL = 525;

// Start Offset
parameter X_START = H_SYNC_CYC + H_SYNC_BACK;
parameter Y_START = V_SYNC_CYC + V_SYNC_BACK;

// Internal Registers and Wires
reg [12:0] H_Cont;
reg [12:0] V_Cont;
reg mVGA_H_SYNC;
reg mVGA_V_SYNC;
wire [9:0] mVGA_R;
wire [9:0] mVGA_G;
wire [9:0] mVGA_B;
wire mVGA_SYNC;
wire mVGA_BLANK;
wire [12:0] v_mask;

assign v_mask = 13'd0; // No zoom mode in this version

// --------------------------------------------------------------------
// Pixel color masking inside active video area
assign mVGA_R = (H_Cont >= X_START && H_Cont < X_START + H_SYNC_ACT &&
                 V_Cont >= Y_START + v_mask && V_Cont < Y_START + V_SYNC_ACT) ? iRed : 10'd0;
assign mVGA_G = (H_Cont >= X_START && H_Cont < X_START + H_SYNC_ACT &&
                 V_Cont >= Y_START + v_mask && V_Cont < Y_START + V_SYNC_ACT) ? iGreen : 10'd0;
assign mVGA_B = (H_Cont >= X_START && H_Cont < X_START + H_SYNC_ACT &&
                 V_Cont >= Y_START + v_mask && V_Cont < Y_START + V_SYNC_ACT) ? iBlue : 10'd0;

assign mVGA_BLANK = mVGA_H_SYNC & mVGA_V_SYNC;
assign mVGA_SYNC  = 1'b0;

// --------------------------------------------------------------------
// Added pixel_x and pixel_y outputs
assign pixel_x = (H_Cont > X_START) ? (H_Cont - X_START) : 10'd0;
assign pixel_y = (V_Cont > Y_START) ? (V_Cont - Y_START) : 10'd0;

// --------------------------------------------------------------------
// Output Registers Update
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        oVGA_R <= 0;
        oVGA_G <= 0;
        oVGA_B <= 0;
        oVGA_BLANK <= 0;
        oVGA_SYNC <= 0;
        oVGA_H_SYNC <= 0;
        oVGA_V_SYNC <= 0;
    end else begin
        oVGA_R <= mVGA_R;
        oVGA_G <= mVGA_G;
        oVGA_B <= mVGA_B;
        oVGA_BLANK <= mVGA_BLANK;
        oVGA_SYNC <= mVGA_SYNC;
        oVGA_H_SYNC <= mVGA_H_SYNC;
        oVGA_V_SYNC <= mVGA_V_SYNC;
    end
end

// --------------------------------------------------------------------
// Pixel LUT Address Generator (oRequest signal)
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N)
        oRequest <= 1'b0;
    else begin
        if (H_Cont >= X_START-2 && H_Cont < X_START + H_SYNC_ACT-2 &&
            V_Cont >= Y_START && V_Cont < Y_START + V_SYNC_ACT)
            oRequest <= 1'b1;
        else
            oRequest <= 1'b0;
    end
end

// --------------------------------------------------------------------
// Horizontal Sync Generator
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        H_Cont <= 0;
        mVGA_H_SYNC <= 0;
    end else begin
        if (H_Cont < H_SYNC_TOTAL)
            H_Cont <= H_Cont + 1;
        else
            H_Cont <= 0;

        if (H_Cont < H_SYNC_CYC)
            mVGA_H_SYNC <= 0;
        else
            mVGA_H_SYNC <= 1;
    end
end

// --------------------------------------------------------------------
// Vertical Sync Generator
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        V_Cont <= 0;
        mVGA_V_SYNC <= 0;
    end else begin
        if (H_Cont == 0) begin
            if (V_Cont < V_SYNC_TOTAL)
                V_Cont <= V_Cont + 1;
            else
                V_Cont <= 0;

            if (V_Cont < V_SYNC_CYC)
                mVGA_V_SYNC <= 0;
            else
                mVGA_V_SYNC <= 1;
        end
    end
end

endmodule
