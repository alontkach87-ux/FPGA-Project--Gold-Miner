// HartsMatrixBitMap File 
// A two level bitmap displaying hearts/objects on the screen Feb 2025 
// (c) Technion IIT, Department of Electrical Engineering 2025 

module MazeMatrixBitMap ( 
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] offsetX, // offset from top left position 
    input  logic [10:0] offsetY,
    input  logic        InsideRectangle, // input that the pixel is within a bracket 
    input  logic        random_hart,     // for levle change
    input  logic        collision_bomb_object,
	 

    output logic        drawingRequest, // output that the pixel should be displayed 
    output logic [7:0]  RGBout,          // rgb value from the bitmap 
	 output logic [9:0]  counter_Score
);

    localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; // RGB value representing transparency 


    localparam int TILE_NUMBER_OF_X_BITS = 5;  // 2^ 5= 32 pixels width
    localparam int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 pixels height

    localparam int TILE_WIDTH_X  = 1 << TILE_NUMBER_OF_X_BITS;
    localparam int TILE_HEIGHT_Y = 1 << TILE_NUMBER_OF_Y_BITS;
	 localparam int BLUEDIAMOND_VALUE = 20;
	 localparam int REDDIAMOND_VALUE = 10;
	 localparam int GOLD_VALUE = 5;
	 localparam int STONE_VALUE = 0;
	 localparam int BLACK_HOLE = -10;
	 


    
    localparam int MAZE_NUMBER_OF__X_BITS = 4; // 2^4 = 16 blocks wide
    localparam int MAZE_NUMBER_OF__Y_BITS = 4; // 2^4 = 16 blocks high (actually will be 10 line, determined by the square object)

    localparam int MAZE_WIDTH_X  = 1 << MAZE_NUMBER_OF__X_BITS; // 16
    localparam int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS; // 16

    localparam int NUM_OBJECTS = 6; 
	 //1 gold
	 //2 stone
	 //3 reddiamond
	 //4 bluediamond
	 //5 strongstone
	 //6 blackhole
    logic [TILE_NUMBER_OF_X_BITS-1:0] offsetX_LSB;
    logic [TILE_NUMBER_OF_Y_BITS-1:0] offsetY_LSB; 
    logic [MAZE_NUMBER_OF__X_BITS-1:0] offsetX_MSB;
    logic [MAZE_NUMBER_OF__Y_BITS-1:0] offsetY_MSB;

    assign offsetX_LSB = offsetX[TILE_NUMBER_OF_X_BITS-1:0]; 
    assign offsetY_LSB = offsetY[TILE_NUMBER_OF_Y_BITS-1:0]; 
    
    assign offsetX_MSB = offsetX[TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS - 1 : TILE_NUMBER_OF_X_BITS]; 
    assign offsetY_MSB = offsetY[TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS - 1 : TILE_NUMBER_OF_Y_BITS]; 

    logic [0:MAZE_HEIGHT_Y-1][0:MAZE_WIDTH_X-1][3:0] MazeBitMapMask;  

    logic [0:MAZE_HEIGHT_Y-1][0:MAZE_WIDTH_X-1][3:0] MazeDefaultBitMapMask = '{
        {64'h2030000000003000},
        {64'h0002040040021000},
        {64'h3000004000403003},
        {64'h4310020000102020},
        {64'h0024044000040002},
        {64'h0000030020001000},
        {64'h0124103210444000},
		  {64'h0124103210444000},
		  {64'h0124103210444000},
		  {64'h0124103210444000},
		  {64'h0000000000000000},
		  {64'h0000000000000000},
		  {64'h0000000000000000},
		  {64'h0000000000000000},
		  {64'h0000000000000000},
        {64'h0000000000000000}
    };

    
    logic [0:NUM_OBJECTS-1][0:TILE_HEIGHT_Y-1][0:TILE_WIDTH_X-1][7:0] object_colors = {
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'h8c,8'hb0,8'hfe,8'hfe,8'hfe,8'hfe,8'hf9,8'hfe,8'hd9,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'h8c,8'hb0,8'hff,8'hfe,8'hd9,8'hb0,8'hd4,8'h8c,8'hd5,8'hf9,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd4,8'hfe,8'hfd,8'hd4,8'hfe,8'hfe,8'hb0,8'hb0,8'hf9,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hf9,8'hfe,8'hfe,8'hb4,8'hf9,8'hf9,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hfe,8'hb0,8'hb0,8'hb0,8'hff,8'hd4,8'hf9,8'hd5,8'hfe,8'hfe,8'hb4,8'hfe,8'hfe,8'hfe,8'hfe,8'hf9,8'hfd,8'hfe,8'hd4,8'hd4,8'hfe,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfd,8'hfe,8'hfe,8'hb0,8'hfc,8'hfd,8'h8c,8'h90,8'hff,8'hb4,8'hf9,8'hfe,8'hfe,8'hfe,8'hfe,8'hf8,8'hfe,8'h6c,8'hfe,8'hfe,8'hd4,8'h90,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hf9,8'hf9,8'hfd,8'hf9,8'hfd,8'hfd,8'hfe,8'hf9,8'hf8,8'hf9,8'hf9,8'hb0,8'h6c,8'hfe,8'hd9,8'h64,8'hb1,8'h64,8'hfe,8'hb0,8'hff,8'h64,8'h8c,8'hff,8'hd4,8'hd5,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hfa,8'hb0,8'hb0,8'hfe,8'hfe,8'hf9,8'hf9,8'hfd,8'hf9,8'hfe,8'hf9,8'hfe,8'h6c,8'h24,8'hb0,8'h64,8'h64,8'hf9,8'hfd,8'hfe,8'hd4,8'hfe,8'h6c,8'h8c,8'hfd,8'hff,8'h6c,8'hff,8'hff,8'hff},
	{8'hff,8'hfe,8'hd5,8'hb0,8'hfe,8'hfe,8'hfe,8'hf9,8'hf9,8'hd9,8'hfe,8'hb4,8'hfc,8'hfe,8'h64,8'hb0,8'h6c,8'h8c,8'hd4,8'hf9,8'hf9,8'hfd,8'hb0,8'hfe,8'h24,8'h8c,8'hd4,8'hfd,8'h8c,8'hfe,8'hff,8'hff},
	{8'hff,8'hb0,8'hb0,8'hff,8'hb0,8'hfd,8'hb4,8'hf9,8'hb0,8'hd4,8'hfe,8'hf9,8'hfd,8'hfd,8'hfe,8'h24,8'h6c,8'hf9,8'hd4,8'hac,8'hf4,8'hfd,8'h64,8'hfe,8'h64,8'h64,8'h8c,8'hd8,8'h8c,8'hfe,8'hff,8'hff},
	{8'hfe,8'hd9,8'h8c,8'hfe,8'h24,8'h8c,8'h24,8'h8c,8'hfd,8'hd8,8'h90,8'hfe,8'hac,8'hfe,8'hfe,8'hf9,8'hf9,8'hfd,8'hfe,8'hb0,8'h24,8'hf9,8'hf9,8'hb0,8'h24,8'h8c,8'hd4,8'hfd,8'hfd,8'hfe,8'hff,8'hff},
	{8'hff,8'h8c,8'hf9,8'hfe,8'h64,8'h8c,8'h24,8'h24,8'h6c,8'h64,8'hb0,8'hd8,8'hff,8'hfd,8'hfd,8'hf9,8'hf9,8'h8c,8'hff,8'h8c,8'hf8,8'hf4,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hf9,8'hd4,8'hfe,8'hff,8'hff},
	{8'h64,8'h64,8'hf9,8'hfd,8'hfd,8'hfd,8'hf9,8'h6c,8'h24,8'h8c,8'h6c,8'h6c,8'hd4,8'hfd,8'hfd,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hb0,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hf9,8'hd4,8'h8c,8'hfe,8'hd5,8'hff},
	{8'h64,8'hd4,8'h8c,8'hf9,8'hfd,8'hfd,8'hf9,8'h24,8'hd5,8'h8c,8'h64,8'hfe,8'hfd,8'hfd,8'hf4,8'hfd,8'hfd,8'hfd,8'hf9,8'hf9,8'hfd,8'hb0,8'hfd,8'hf4,8'hf8,8'hf9,8'h8c,8'h64,8'hd4,8'hd4,8'h8c,8'hff},
	{8'hfd,8'hf9,8'hd4,8'h8c,8'hf9,8'hfd,8'hf9,8'h64,8'hd5,8'h64,8'h8c,8'h64,8'hf9,8'hf8,8'hf9,8'hfd,8'hf9,8'hfd,8'hf9,8'hf9,8'hf8,8'hd0,8'hf9,8'hf9,8'h24,8'h8c,8'h64,8'h6c,8'hd4,8'hd9,8'hfa,8'hb0},
	{8'hfd,8'hfd,8'h8c,8'h24,8'h6c,8'h8c,8'hb0,8'h8c,8'h8c,8'hfe,8'h90,8'h6c,8'hd0,8'hac,8'hb0,8'hfd,8'hfd,8'hf9,8'hf9,8'hf8,8'hf9,8'hb0,8'hac,8'h64,8'h6c,8'h6c,8'hfd,8'h64,8'h64,8'hb0,8'hd9,8'hd9},
	{8'hfe,8'h8c,8'h6c,8'h64,8'h64,8'hfe,8'hfe,8'h8c,8'hd4,8'hff,8'h8c,8'h64,8'hff,8'hd5,8'h6c,8'hd4,8'hf9,8'hfd,8'hfd,8'hfd,8'hd9,8'hd5,8'h24,8'hac,8'hac,8'h64,8'hb5,8'h24,8'h6c,8'hfe,8'hff,8'hd5},
	{8'hd4,8'hb0,8'hfd,8'h8c,8'hf9,8'hff,8'hd8,8'hb0,8'hfe,8'hfe,8'hfe,8'hb4,8'hfe,8'hff,8'hd4,8'h8c,8'h6c,8'h6c,8'h6c,8'hd4,8'h64,8'h24,8'h64,8'hfd,8'h64,8'hd5,8'h90,8'h24,8'h8c,8'hfd,8'hb0,8'hb0},
	{8'h90,8'hf8,8'hd4,8'hfe,8'hfe,8'hff,8'hfe,8'hd4,8'hd0,8'hac,8'hfe,8'hfe,8'hfc,8'hfd,8'hff,8'hd8,8'hb0,8'hb0,8'hb0,8'h8c,8'h64,8'h24,8'h8c,8'hfe,8'h6c,8'h8c,8'h6c,8'h8c,8'hfd,8'hf9,8'hd5,8'hfd},
	{8'h8c,8'h6c,8'h6c,8'hf9,8'hfe,8'hfd,8'hf8,8'hfc,8'hb0,8'hfe,8'hfe,8'hfe,8'hd8,8'hd8,8'hfe,8'hd4,8'hff,8'hf9,8'h90,8'hb4,8'h24,8'h8c,8'h6c,8'h64,8'h24,8'h8c,8'hb0,8'hf9,8'hfe,8'hf9,8'hf9,8'hf9},
	{8'hd8,8'h64,8'hb0,8'hff,8'hfd,8'hd4,8'hfe,8'hff,8'h8c,8'h6c,8'h8c,8'hff,8'hff,8'hac,8'hfe,8'hfd,8'hfd,8'hb0,8'h8c,8'hb4,8'h24,8'hf8,8'h64,8'hf9,8'hf9,8'hd5,8'hf9,8'hfd,8'hf9,8'hfd,8'hf9,8'hfd},
	{8'hfd,8'h6c,8'hfd,8'hfe,8'hff,8'h8c,8'h90,8'hd8,8'h64,8'hfd,8'h6c,8'hb0,8'hf9,8'hfe,8'hb0,8'hff,8'hfd,8'hfd,8'hfd,8'hf9,8'hf9,8'hf9,8'hf4,8'hf9,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hfd,8'hac,8'hfd},
	{8'hfd,8'hfd,8'hb0,8'hfd,8'h8c,8'h6c,8'hf9,8'hd9,8'hf9,8'hfd,8'hf9,8'hfd,8'hd4,8'hb0,8'hb0,8'hfd,8'hf9,8'hf9,8'hfd,8'hfd,8'hf8,8'hf9,8'hf9,8'hf9,8'hd4,8'hf9,8'hfd,8'hfd,8'hfd,8'hf9,8'hfd,8'hfd},
	{8'hd5,8'hfa,8'hf9,8'h90,8'h64,8'hf9,8'hf9,8'hfd,8'hf9,8'hfd,8'hf9,8'hf9,8'h8c,8'hfe,8'hf9,8'hf9,8'hd4,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hf9,8'hfd,8'hf9,8'hf9,8'hfd,8'hfd,8'hd4,8'hf8,8'hf8,8'hfd},
	{8'hfd,8'hd9,8'hfe,8'hfe,8'hf9,8'hf9,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'h64,8'hf9,8'hfd,8'hf9,8'hd0,8'hd4,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'h64,8'h24,8'hf8,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'hf9,8'hfd},
	{8'hff,8'hd5,8'hd5,8'hfa,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'h24,8'hf9,8'hfd,8'hfd,8'hf9,8'hb0,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hfd,8'hd4,8'hb0,8'hfe,8'hf9,8'hb0,8'hfe,8'hfe,8'hfe},
	{8'hff,8'hff,8'hd5,8'hf9,8'hd9,8'hf9,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'hf9,8'hf9,8'hd4,8'hd4,8'hfd,8'hfd,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hf9,8'hb0,8'hf9,8'hfd,8'hff},
	{8'hff,8'hff,8'hff,8'hd5,8'hf9,8'hd9,8'hd5,8'hfd,8'hf9,8'hfd,8'hfd,8'hd5,8'hf9,8'hd0,8'hd4,8'hb0,8'h64,8'hf9,8'hf9,8'hf9,8'hd4,8'hf9,8'hf9,8'hfd,8'hf9,8'hfd,8'hf9,8'hfe,8'hfd,8'hf9,8'hf9,8'hff},
	{8'hff,8'hff,8'hff,8'hf9,8'hd5,8'hb1,8'hb0,8'hd4,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'hd0,8'hf8,8'hfd,8'h8c,8'hfd,8'hfd,8'hfd,8'hfd,8'hd4,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hfd,8'hfd,8'hfe,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hd9,8'hf9,8'hb4,8'hf9,8'hf9,8'hd4,8'hb0,8'hd9,8'hf9,8'hd4,8'hfd,8'hf9,8'hfe,8'hf8,8'hf4,8'hf9,8'hf9,8'h6c,8'hf9,8'hd4,8'hf9,8'hf9,8'hfd,8'hf9,8'hfd,8'hfe,8'hfe,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hd5,8'hfd,8'hf9,8'hf9,8'hd4,8'hd9,8'hb0,8'hd9,8'hf9,8'hf9,8'hfd,8'hfd,8'hd0,8'hb0,8'hb0,8'hf9,8'hf9,8'hf9,8'h8c,8'hf8,8'hf9,8'hfa,8'hfe,8'hfd,8'hfe,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hfe,8'hfe,8'hd5,8'hd5,8'hf9,8'hf9,8'hf9,8'hf9,8'hb0,8'hb5,8'hf9,8'hf9,8'hf9,8'hfd,8'hfd,8'hf9,8'hd4,8'h6c,8'h6c,8'hb0,8'hf8,8'hf9,8'hf9,8'hd9,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hfe,8'hfe,8'hfa,8'hfa,8'hfe,8'hb5,8'hd4,8'hd4,8'hf9,8'hf9,8'hd5,8'hd5,8'hf9,8'hf9,8'hf9,8'hf9,8'h8c,8'h8c,8'h8c,8'hd4,8'hfd,8'hf9,8'hd9,8'hf9,8'hf9,8'hf9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
   },

	{{8'h91,8'hd6,8'hda,8'h24,8'h91,8'hb6,8'h24,8'h24,8'h24,8'h8d,8'h91,8'h24,8'hb5,8'hd5,8'h8d,8'hb1,8'h91,8'hb1,8'hb6,8'h91,8'hb5,8'hb5,8'hd5,8'hb1,8'h6c,8'hda,8'h91,8'hd5,8'hb5,8'hfa,8'hfa,8'hb5},
	{8'h91,8'hda,8'h91,8'h91,8'hb5,8'hda,8'hb5,8'hb5,8'hb1,8'hb1,8'h24,8'h24,8'hb5,8'h24,8'hb5,8'hb5,8'hd6,8'h91,8'hb5,8'hda,8'hb5,8'h6c,8'h91,8'hda,8'h91,8'h91,8'h6c,8'h6d,8'hda,8'h8c,8'hb5,8'hd5},
	{8'h91,8'hb5,8'hb5,8'h8d,8'h6c,8'hb5,8'hb5,8'hda,8'hda,8'hda,8'hda,8'hb5,8'hda,8'h91,8'hda,8'hda,8'hb1,8'hda,8'hb5,8'h91,8'hda,8'hda,8'h91,8'hb5,8'h91,8'hb5,8'hda,8'hb5,8'hd6,8'h90,8'h8c,8'h91},
	{8'hda,8'hfe,8'h64,8'h6c,8'h24,8'hb5,8'hb5,8'hda,8'hfa,8'hda,8'hb5,8'hb5,8'hda,8'h91,8'hda,8'hb5,8'hb5,8'hfe,8'h91,8'hb6,8'hb5,8'hb5,8'hb5,8'hb5,8'hfe,8'hb1,8'h6c,8'hb5,8'h8d,8'hda,8'hb5,8'hb5},
	{8'hb5,8'h91,8'hb5,8'hb5,8'h24,8'hda,8'hb6,8'hb5,8'hb6,8'hda,8'hb5,8'hb6,8'h24,8'h91,8'h6c,8'h6c,8'h91,8'hb6,8'h91,8'h91,8'hb5,8'h6d,8'hb1,8'hb6,8'hfa,8'hb5,8'hb1,8'hd5,8'h8c,8'hb5,8'hd5,8'hb5},
	{8'h91,8'h6c,8'hb5,8'h00,8'hb5,8'h6c,8'h6c,8'h6c,8'hb5,8'hb5,8'h91,8'hda,8'hd5,8'h91,8'h8d,8'hb5,8'hb6,8'hb5,8'h24,8'h6d,8'h91,8'h24,8'hb6,8'h91,8'hb6,8'hda,8'hb5,8'hd5,8'h6c,8'h91,8'hff,8'hfa},
	{8'hb1,8'h91,8'hb1,8'hb5,8'h91,8'h91,8'h6c,8'hb6,8'hda,8'h91,8'hb5,8'hb5,8'hb5,8'hb1,8'hd6,8'hb5,8'hb6,8'h91,8'h6c,8'h6c,8'h91,8'h6d,8'hb5,8'hd6,8'h91,8'hb5,8'hd6,8'hd6,8'hb5,8'hb1,8'hb1,8'h6c},
	{8'h6c,8'h24,8'h24,8'h00,8'h24,8'h6c,8'hb5,8'h91,8'hb5,8'h6c,8'hb5,8'hb5,8'h6c,8'h90,8'hd6,8'h6c,8'h24,8'h90,8'h70,8'hb5,8'hfe,8'hb5,8'h91,8'h91,8'h91,8'hd5,8'hda,8'hb5,8'hfe,8'hda,8'hfa,8'hda},
	{8'h6c,8'h6c,8'h6c,8'h8c,8'h24,8'h6c,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'h6c,8'h90,8'hb5,8'hfa,8'hb5,8'h6c,8'h91,8'hda,8'hfe,8'hd5,8'hd5,8'hb5,8'hb5,8'hd5,8'hb1,8'hb1,8'hb1,8'h91,8'hb1},
	{8'h91,8'h6c,8'h91,8'h24,8'hb5,8'h24,8'h6c,8'h91,8'hb6,8'hb5,8'hb5,8'h6d,8'h91,8'hb1,8'h91,8'hb5,8'hb5,8'h91,8'h91,8'h91,8'hb5,8'h6d,8'hda,8'hd5,8'h91,8'hd6,8'hda,8'hda,8'hb5,8'h6c,8'hd5,8'hd5},
	{8'h24,8'hda,8'h91,8'hb6,8'hb1,8'h24,8'h00,8'hb1,8'h6d,8'h6d,8'h6c,8'h91,8'hb5,8'hd6,8'hb5,8'h91,8'hb5,8'hb5,8'h6c,8'h91,8'h91,8'h8d,8'hda,8'hd5,8'hd9,8'hd5,8'hb1,8'hfe,8'hb1,8'hd9,8'hd5,8'hb5},
	{8'h91,8'hb5,8'h24,8'hb5,8'hb5,8'h91,8'h90,8'h24,8'h24,8'h91,8'hd5,8'h91,8'h91,8'h91,8'h24,8'hb1,8'hd6,8'h91,8'h24,8'hb5,8'h6d,8'h91,8'hd5,8'hda,8'hd9,8'hd5,8'h91,8'hb1,8'hb1,8'h91,8'hd9,8'hd5},
	{8'h24,8'h24,8'h6d,8'h6c,8'hb1,8'hb5,8'h90,8'h6c,8'hda,8'hb5,8'h91,8'h6c,8'hb5,8'hda,8'hb5,8'hb5,8'h91,8'h91,8'hb5,8'h00,8'h24,8'h91,8'hd5,8'hda,8'h90,8'hb5,8'hd9,8'h91,8'hfe,8'hd5,8'h91,8'hb5},
	{8'h6c,8'h04,8'h24,8'h24,8'h91,8'h24,8'h24,8'hb5,8'h91,8'h6c,8'h04,8'hb5,8'hb5,8'h00,8'h24,8'hb1,8'hb5,8'hb5,8'h91,8'h91,8'hb1,8'h8c,8'h6d,8'hd5,8'hb5,8'hb5,8'hd5,8'hb1,8'h6c,8'hda,8'hb5,8'hfa},
	{8'h24,8'h6c,8'h00,8'h24,8'h6d,8'h24,8'h24,8'h00,8'h24,8'h6c,8'h6c,8'h91,8'h6c,8'h90,8'h91,8'h91,8'h91,8'h91,8'hb6,8'hfe,8'hd6,8'hb1,8'hb5,8'h6c,8'hd5,8'hb1,8'hb5,8'hd5,8'h91,8'hda,8'hb1,8'hd9},
	{8'h00,8'h24,8'h00,8'h24,8'h24,8'h6c,8'h24,8'h24,8'h24,8'h24,8'h6d,8'hb5,8'h24,8'hb5,8'h6c,8'hb1,8'hb5,8'hb1,8'hda,8'hda,8'h91,8'hb1,8'hda,8'h91,8'hb5,8'hd5,8'hd9,8'hb1,8'hd5,8'h91,8'hfa,8'hd9},
	{8'h24,8'h6d,8'h00,8'h24,8'h24,8'h6c,8'h00,8'h24,8'h24,8'h24,8'h24,8'h91,8'hb1,8'h20,8'h91,8'h91,8'hb5,8'hda,8'h8c,8'hd5,8'hd5,8'hb1,8'hfe,8'h6c,8'h24,8'hda,8'hd5,8'h91,8'hd5,8'hb5,8'hd9,8'hda},
	{8'h24,8'h24,8'h00,8'h24,8'h6c,8'h04,8'h24,8'h6c,8'h00,8'h24,8'h24,8'h6c,8'h24,8'hda,8'h91,8'hb1,8'hda,8'hb1,8'hb5,8'h91,8'hfe,8'hb5,8'hd5,8'hf9,8'h6c,8'hd5,8'hd5,8'h6c,8'hfa,8'hb1,8'h8c,8'hda},
	{8'h6c,8'h00,8'h04,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6c,8'h24,8'h2c,8'h24,8'h24,8'h24,8'hb6,8'hfa,8'hd5,8'hb1,8'hfa,8'hb5,8'hb5,8'h6c,8'hd5,8'hfa,8'hb1,8'h6c,8'h90,8'h04,8'h04,8'hb5,8'h00,8'hda},
	{8'h6c,8'h6d,8'h04,8'h24,8'h00,8'h24,8'h6c,8'h24,8'h24,8'h24,8'h24,8'h6c,8'h24,8'h24,8'h24,8'hb1,8'hd5,8'hd5,8'hd5,8'hb5,8'hfa,8'hb5,8'h6d,8'hfe,8'hd5,8'h00,8'h6c,8'h6c,8'h91,8'h91,8'h00,8'hda},
	{8'h24,8'hb5,8'h8d,8'h24,8'h00,8'h24,8'h04,8'h24,8'h2c,8'h00,8'h00,8'h6c,8'h24,8'h00,8'h24,8'h24,8'hd9,8'hd5,8'hd6,8'hb5,8'hf9,8'hb1,8'hb1,8'h64,8'h64,8'h91,8'h91,8'hff,8'h91,8'hfa,8'hb5,8'hb1},
	{8'h24,8'h91,8'h24,8'h6c,8'h91,8'h24,8'h00,8'h04,8'h24,8'h04,8'h6c,8'h24,8'h04,8'h24,8'h6c,8'h24,8'h00,8'hda,8'hb5,8'h6c,8'hb5,8'h24,8'h8d,8'h64,8'h24,8'h91,8'h6c,8'hb1,8'hda,8'hd5,8'hda,8'hd5},
	{8'h00,8'h6c,8'h24,8'h00,8'h00,8'hb5,8'h24,8'h24,8'h24,8'h00,8'h04,8'h24,8'h24,8'h00,8'h00,8'h20,8'h24,8'h00,8'hd5,8'hd5,8'hb5,8'h91,8'hda,8'hb5,8'hfa,8'hb1,8'h24,8'h91,8'hfa,8'h91,8'hb5,8'hb5},
	{8'h24,8'h24,8'h24,8'h24,8'hda,8'h00,8'h6d,8'h91,8'h24,8'h00,8'h6d,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h64,8'h91,8'h24,8'hd5,8'hb5,8'hd5,8'hd5,8'h24,8'hb5,8'hb5,8'hb5,8'h6c,8'h91},
	{8'h00,8'h6c,8'h24,8'h6d,8'h24,8'h24,8'h00,8'h24,8'h91,8'hb5,8'h91,8'h91,8'hb6,8'h24,8'h24,8'h6c,8'h24,8'h6c,8'h6c,8'h6c,8'hda,8'hb1,8'hda,8'hb5,8'hda,8'hd5,8'hb1,8'h24,8'hb5,8'hd5,8'hb5,8'h00},
	{8'h00,8'h6c,8'h6c,8'h91,8'h91,8'h24,8'h24,8'h00,8'h24,8'h8d,8'hb5,8'hb5,8'h6d,8'hb5,8'h24,8'hb5,8'hb5,8'h91,8'hfa,8'hb5,8'hfa,8'h6c,8'h91,8'hd5,8'hda,8'hb5,8'h6c,8'h24,8'hd5,8'hb5,8'hd5,8'h24},
	{8'h6c,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hda,8'h91,8'hb1,8'h91,8'h91,8'hb5,8'hb1,8'hfa,8'hb5,8'hb1,8'hfe,8'hb5,8'hd5,8'hb5,8'hb1,8'hb1,8'hd5,8'h24,8'hda,8'hd9,8'hd5,8'h6c},
	{8'h00,8'h6d,8'h24,8'h6c,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h91,8'h91,8'h6d,8'hb5,8'hfe,8'hb1,8'hb5,8'hd5,8'h91,8'hb1,8'hb1,8'hb1,8'h24,8'hda,8'hb1,8'hb5,8'hd9,8'h24,8'h24,8'hfe,8'hd5,8'h6c},
	{8'h2c,8'h24,8'h24,8'h00,8'h24,8'h6c,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h6c,8'h91,8'hfa,8'hda,8'hda,8'h8c,8'hd5,8'hd5,8'h90,8'hb5,8'hb1,8'h91,8'hb5,8'hfa,8'hd5,8'hd5,8'h24,8'hb5,8'h8c,8'h24},
	{8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h24,8'h24,8'h64,8'h6c,8'hd9,8'hb1,8'hfa,8'hd5,8'hda,8'hd5,8'hb5,8'h24,8'hfa,8'hfa,8'hfa,8'h24,8'h24,8'h6c,8'h8d},
	{8'h6c,8'h6d,8'h24,8'h24,8'h04,8'h6d,8'h00,8'h6d,8'h24,8'h6c,8'h04,8'h04,8'h00,8'h24,8'h24,8'hda,8'hb5,8'h91,8'hd5,8'h64,8'hda,8'hb5,8'hb5,8'h91,8'h91,8'hb5,8'hd5,8'h6c,8'h90,8'h91,8'hda,8'hb1},
	{8'h91,8'h6d,8'h24,8'h00,8'h24,8'h24,8'h2c,8'h04,8'h24,8'h24,8'h00,8'h24,8'h24,8'h24,8'h00,8'h91,8'h6c,8'hb5,8'hb1,8'hb5,8'hd5,8'h64,8'hb1,8'h6c,8'h91,8'hb5,8'hfa,8'h6c,8'h91,8'hd5,8'h91,8'hd5}

        },

	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'h80,8'h00,8'hd6,8'h00,8'he5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'had,8'h60,8'h20,8'hda,8'hda,8'hff,8'h60,8'hed,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hff,8'hff,8'h60,8'ha0,8'hc0,8'h60,8'hff,8'hff,8'ha0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'h64,8'hff,8'h60,8'h20,8'ha0,8'ha0,8'h20,8'h60,8'hff,8'h24,8'h80,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h64,8'h60,8'he1,8'h60,8'h20,8'h20,8'h60,8'h60,8'h20,8'h64,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf1,8'hda,8'ha0,8'h00,8'h20,8'h20,8'h60,8'h60,8'h00,8'hc0,8'hb6,8'hf1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h20,8'h60,8'h00,8'h20,8'hc0,8'hed,8'hc0,8'h00,8'h60,8'h60,8'h84,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h20,8'h00,8'h00,8'ha0,8'hc0,8'hc0,8'h60,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'h80,8'hc0,8'he5,8'h20,8'h20,8'h20,8'h20,8'h80,8'h20,8'ha0,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'h8d,8'h20,8'ha0,8'h20,8'h20,8'h20,8'h00,8'h20,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8d,8'h20,8'h20,8'hed,8'hc0,8'h20,8'h00,8'h60,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h00,8'h00,8'h60,8'he0,8'h20,8'h60,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}

        },
		  
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h06,8'h05,8'h00,8'hdf,8'h00,8'hd3,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6e,8'h05,8'h05,8'hda,8'hda,8'hff,8'h05,8'h93,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'hff,8'hff,8'h01,8'h06,8'h0f,8'h01,8'hff,8'hff,8'h26,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb7,8'h25,8'hff,8'h05,8'h00,8'h06,8'h0e,8'h00,8'h01,8'hff,8'h24,8'h05,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h2d,8'h01,8'haf,8'h01,8'h00,8'h00,8'h01,8'h01,8'h00,8'h05,8'h25,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb7,8'hdb,8'h06,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h62,8'hba,8'hb7,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h00,8'h01,8'h00,8'h00,8'h26,8'h93,8'h0f,8'h00,8'h01,8'h25,8'h25,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h01,8'h00,8'h00,8'h06,8'h73,8'h26,8'h06,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h05,8'h05,8'h6e,8'h8f,8'h00,8'h01,8'h00,8'h00,8'h05,8'h00,8'h06,8'h05,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h66,8'h25,8'h00,8'h01,8'h00,8'h01,8'h00,8'h00,8'h00,8'h97,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'h6d,8'h00,8'h00,8'h93,8'h2e,8'h01,8'h00,8'h01,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h00,8'h00,8'h01,8'h2f,8'h00,8'h26,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
   },
	
	{
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}

	},
	
	
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
		}};


    
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGBout <= 8'h00;
            MazeBitMapMask <= MazeDefaultBitMapMask;
				counter_Score <= 0;
        end
        else begin
            RGBout <= TRANSPARENT_ENCODING; // Default
            
        if (collision_bomb_object) begin
            
            case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                4'd1: counter_Score <= counter_Score + GOLD_VALUE;       
                4'd2: counter_Score <= counter_Score + STONE_VALUE; 
                4'd3: counter_Score <= counter_Score + REDDIAMOND_VALUE; 
                4'd4: counter_Score <= counter_Score + BLUEDIAMOND_VALUE;
					 4'd5: counter_Score <= counter_Score + STONE_VALUE;
					 4'd6: counter_Score <= counter_Score + BLACK_HOLE;
                default: counter_Score <= counter_Score;
            endcase
				MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
        end
					 
					 
			if (InsideRectangle) begin 
                case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                    4'd0: RGBout <= TRANSPARENT_ENCODING;
                    
                    4'd1: RGBout <= object_colors[0][offsetY_LSB][offsetX_LSB]; 
								 
                    4'd2: RGBout <= object_colors[1][offsetY_LSB][offsetX_LSB];
								 
                    4'd3: RGBout <= object_colors[2][offsetY_LSB][offsetX_LSB];
						      
                    4'd4: RGBout <= object_colors[3][offsetY_LSB][offsetX_LSB];
						  
						  4'd5: RGBout <= object_colors[4][offsetY_LSB][offsetX_LSB];
						  
						  4'd6: RGBout <= object_colors[5][offsetY_LSB][offsetX_LSB];
						  
						        
                    default: RGBout <= TRANSPARENT_ENCODING;
                endcase
            end 
        end 
    end

    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING);

endmodule