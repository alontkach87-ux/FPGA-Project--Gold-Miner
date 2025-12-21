module square_object_bomb (
    input  logic        clk,
    input  logic        resetN,
    input  logic signed [10:0] pixelX,
    input  logic signed [10:0] pixelY,
    input  logic signed [10:0] topLeftX,
    input  logic signed [10:0] topLeftY,

    input  logic        EnableScale,
    input  logic [7:0]  explosionRadius,

    output logic [10:0] offsetX,
    output logic [10:0] offsetY,
    output logic        drawingRequest,
    output logic [15:0] scale_fp_out
);

localparam int BASE_SIZE = 32;
localparam int CENTER    = 16;
localparam int FIX_FRAC  = 64;

logic [15:0] scale_fp;
logic [11:0] scaled_size;

logic signed [12:0] new_topLeftX, new_topLeftY;
logic signed [12:0] rightX, bottomY;
logic insideBracket;

// --- scale calculation ---  scale = 1.0 + 3.0 * explosionRadius / 255 *64 (factor for floating point)
assign scale_fp = 
    FIX_FRAC + (explosionRadius * 16'd3 * FIX_FRAC) / 16'd255;

assign scale_fp_out = EnableScale ? scale_fp : FIX_FRAC;

// --- scaled size in pixels ---
assign scaled_size = (BASE_SIZE * scale_fp_out) / FIX_FRAC;

// --- shift top-left to keep center fixed ---
assign new_topLeftX = topLeftX + CENTER - (scaled_size / 2);
assign new_topLeftY = topLeftY + CENTER - (scaled_size / 2);

assign rightX  = new_topLeftX + scaled_size;
assign bottomY = new_topLeftY + scaled_size;

assign insideBracket =
    (pixelX >= new_topLeftX) && (pixelX < rightX) &&
    (pixelY >= new_topLeftY) && (pixelY < bottomY);

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        drawingRequest <= 1'b0;
        offsetX <= 0;
        offsetY <= 0;
    end else begin
        drawingRequest <= 1'b0;
        offsetX <= 0;
        offsetY <= 0;

        if (insideBracket) begin
            drawingRequest <= 1'b1;
            offsetX <= pixelX - new_topLeftX;
            offsetY <= pixelY - new_topLeftY;
        end
    end
end

endmodule
