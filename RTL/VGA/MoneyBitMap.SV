 module MoneyBitMap (
    input logic clk,
    input logic resetN,
    input logic [10:0] offsetX,      // Provided by square_object
    input logic [10:0] offsetY,      // Provided by square_object
    input logic InsideRectangle,     // Provided by square_object    
    output logic drawingRequest,
    output logic [7:0] RGBout
);
	localparam  int OBJECT_HEIGHT_Y =16;  
	localparam  int OBJECT_WIDTH_X =32;  
	
	logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'h1c,8'h1c,8'hff,8'h1c,8'h1c},
	{8'h1c,8'h1c,8'hff,8'h1c,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'h1c,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'hff},
	{8'h1c,8'hff,8'h1c,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff},
	{8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff},
	{8'h1c,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h1c,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

	
	logic [7:0] current_pixel_color;

    always_comb begin
        // 1. Get the color from the array
        current_pixel_color = object_colors[offsetY][offsetX];
        
        // 2. Default Output
        RGBout = current_pixel_color;
        
        // 3. Logic: Draw only if inside rect AND not white
        if (InsideRectangle == 1'b1 && current_pixel_color != 8'hFF) begin
            drawingRequest = 1'b1;
        end
        else begin
            drawingRequest = 1'b0;
        end
    end
    
endmodule