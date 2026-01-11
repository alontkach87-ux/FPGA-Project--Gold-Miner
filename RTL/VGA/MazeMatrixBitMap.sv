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
	 input  logic        newLevel,
	 input  logic [1:0]  level_input,      // 1, 2, 3
    input  logic [2:0]  map_randomizer,   // 0-5
	 

    output logic        drawingRequest, // output that the pixel should be displayed 
    output logic [7:0]  RGBout,          // rgb value from the bitmap 
	 output logic [9:0]  counter_Score,
	 output logic Is_Rock
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

    localparam int NUM_OBJECTS = 8; 
	 //1 gold
	 //2 stone
	 //3 reddiamond
	 //4 bluediamond
	 //5 strongstone
	 //6 blackhole
	 //7 crakedstone
    logic [TILE_NUMBER_OF_X_BITS-1:0] offsetX_LSB;
    logic [TILE_NUMBER_OF_Y_BITS-1:0] offsetY_LSB; 
    logic [MAZE_NUMBER_OF__X_BITS-1:0] offsetX_MSB;
    logic [MAZE_NUMBER_OF__Y_BITS-1:0] offsetY_MSB;

    assign offsetX_LSB = offsetX[TILE_NUMBER_OF_X_BITS-1:0]; 
    assign offsetY_LSB = offsetY[TILE_NUMBER_OF_Y_BITS-1:0]; 
    
    assign offsetX_MSB = offsetX[TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS - 1 : TILE_NUMBER_OF_X_BITS]; 
    assign offsetY_MSB = offsetY[TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS - 1 : TILE_NUMBER_OF_Y_BITS]; 

    logic [0:MAZE_HEIGHT_Y-1][0:MAZE_WIDTH_X-1][3:0] MazeBitMapMask;  

    logic [0:MAZE_HEIGHT_Y-1][0:MAZE_WIDTH_X-1][3:0] MazeDefaultBitMapMask;
	 
    
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
		},
		
		
	{{8'hb5,8'hb5,8'hb6,8'hb5,8'hb5,8'h91,8'hb5,8'hb1,8'hb5,8'h91,8'h91,8'h24,8'hb1,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'h00,8'h24,8'hb5,8'hb6,8'hb6,8'hb6,8'hb1,8'hb5,8'hd6,8'hb5,8'hb5,8'hb5,8'hb5,8'hb6},
	{8'hb5,8'hb5,8'hb5,8'hb1,8'h91,8'hb1,8'hb5,8'hb1,8'hb5,8'hb1,8'hb5,8'h00,8'hb5,8'h91,8'h91,8'hb5,8'hb5,8'hb5,8'h24,8'h64,8'hb5,8'h91,8'hb5,8'hb1,8'hb5,8'hb1,8'hda,8'hb5,8'hb5,8'h8d,8'hb1,8'hb5},
	{8'hb5,8'hb5,8'hb1,8'h91,8'hb1,8'hb1,8'hb5,8'hb5,8'hb5,8'h91,8'hb1,8'hb5,8'hb5,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'h00,8'h00,8'hb5,8'h91,8'h91,8'h91,8'hb5,8'hb5,8'h91,8'h91,8'hb1,8'h6d,8'hb1,8'hb1},
	{8'hb5,8'hb5,8'h91,8'hb1,8'hb1,8'hb5,8'hb1,8'hb5,8'h6c,8'h00,8'hb1,8'hb5,8'hb5,8'h91,8'h91,8'hb1,8'hb5,8'h91,8'hb5,8'h00,8'hb5,8'h91,8'hb1,8'hb1,8'hb5,8'hb5,8'h91,8'hb5,8'h91,8'hb1,8'hb5,8'hb5},
	{8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'h91,8'hb5,8'h00,8'hb5,8'hb5,8'hb1,8'hb1,8'hb1,8'hb5,8'hb5,8'hb5,8'hb1,8'h24,8'h91,8'h91,8'h91,8'hb1,8'hb5,8'hb1,8'hb5,8'h91,8'h91,8'h91,8'hb1,8'h91,8'hb1},
	{8'hb5,8'hb5,8'h91,8'hb5,8'hb5,8'h91,8'h91,8'hb5,8'h00,8'h91,8'h91,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'hb1,8'h91,8'h24,8'hb5,8'h91,8'h91,8'hb1,8'hb1,8'hb1,8'hb5,8'hb5,8'hb1,8'hb1,8'h91,8'hb1,8'h6c},
	{8'hb5,8'hb5,8'hb1,8'h91,8'h91,8'h91,8'h91,8'h6c,8'h00,8'h91,8'hb1,8'hb1,8'h91,8'hb1,8'hb1,8'hb5,8'h24,8'h24,8'h24,8'hb5,8'h91,8'h91,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'h91,8'hb5,8'hb1,8'hb5},
	{8'hb6,8'hb1,8'h91,8'h91,8'h91,8'h24,8'h6c,8'h00,8'hb5,8'hb1,8'hb1,8'hb5,8'h91,8'hb1,8'h24,8'h00,8'hd6,8'h24,8'h00,8'h91,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'h00,8'h24,8'hb1,8'hb1,8'h24,8'hb1,8'hb5},
	{8'hb5,8'hb1,8'hb5,8'h91,8'h91,8'h24,8'h91,8'h91,8'hb1,8'hb1,8'hb5,8'hb1,8'h91,8'hb1,8'h24,8'hb5,8'hb5,8'hb6,8'h00,8'hb5,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'hb5,8'hb5,8'hb1,8'h91,8'hb5},
	{8'hb5,8'hb1,8'hd6,8'hb5,8'h24,8'h91,8'h91,8'hb1,8'h91,8'hb1,8'hb5,8'hb5,8'hb1,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'h00,8'hb5,8'h91,8'h91,8'h91,8'hb5},
	{8'h00,8'h6d,8'h24,8'h24,8'h6c,8'h24,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'hb1,8'h91,8'h91,8'hb5,8'hb5},
	{8'hb5,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb1,8'h91,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'hda,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb1,8'h91,8'hb1,8'hb6},
	{8'hb5,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb1,8'h24,8'h24,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'h20,8'h6d,8'h6d,8'hd6,8'hb5,8'hd6,8'h00,8'hb1,8'hb5,8'hb1,8'h91,8'hb1,8'hb5},
	{8'hb5,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'h24,8'hda,8'hb5,8'hb1,8'hb5,8'hb5,8'h24,8'h64,8'h00,8'h24,8'h24,8'h24,8'hb5,8'hb5,8'hb5},
	{8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'h6c,8'h00,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h6d,8'h91,8'h91,8'h91,8'h24,8'h00,8'h20,8'h00},
	{8'hb1,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb6,8'hb5,8'hb5,8'hb1,8'hd6,8'hb5,8'hd6,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb5},
	{8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hb1,8'hb5,8'hd6,8'hb5,8'hb5,8'hb1,8'h00,8'hb5,8'h6d,8'hd5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hd6,8'hb5,8'h91,8'h6d,8'h8d,8'h91,8'h91,8'hb5},
	{8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5,8'hda,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'h20,8'hb5,8'hb5,8'hb5,8'hb1,8'hb1,8'h91,8'hb1,8'h24,8'hb1,8'hb1,8'hb1,8'hb1,8'h91,8'h91,8'hb5},
	{8'hb5,8'h91,8'h91,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb1,8'h00,8'hb5,8'hb5,8'h24,8'h24,8'hd6,8'hd5,8'h00,8'hb5,8'hb5,8'hb1,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb1,8'h91,8'h91,8'hb1,8'h91,8'hb5},
	{8'hd6,8'hb1,8'h91,8'hb5,8'h64,8'h24,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'h24,8'h24,8'hd6,8'hb5,8'hb5,8'hb5,8'h00,8'hb5,8'hb5,8'hb1,8'hb5,8'hb1,8'hb5,8'hb5,8'hb6,8'h91,8'hb5,8'h91,8'hb5,8'hb5,8'hb1},
	{8'h24,8'h6c,8'h6c,8'h24,8'h00,8'h00,8'hb5,8'hb5,8'hb5,8'h91,8'hb5,8'h00,8'hb5,8'h91,8'hb1,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h6c,8'h00,8'h24,8'h24,8'hb5,8'hb5,8'hb1,8'hb1},
	{8'hb5,8'hd6,8'hb5,8'h24,8'h91,8'hb1,8'h24,8'hb5,8'hb5,8'hb5,8'h6c,8'h24,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'h6c,8'h6c,8'hb5,8'hb5,8'h64,8'hb5,8'hb5,8'hb5,8'hb5,8'hd6,8'hb5,8'hb5,8'hb5},
	{8'hb6,8'hb5,8'hb5,8'hb1,8'hb1,8'h91,8'hb1,8'h24,8'hb1,8'h24,8'h24,8'h00,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h6c,8'h00,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h00,8'hb5,8'hb5},
	{8'hb5,8'hb1,8'h91,8'h91,8'hb5,8'hb1,8'hb5,8'hb5,8'h24,8'hb5,8'h64,8'hb6,8'hb5,8'hb1,8'h91,8'hb1,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb5},
	{8'hb1,8'hb1,8'hb5,8'h24,8'hb1,8'h91,8'hb5,8'hb5,8'hb5,8'h24,8'h6c,8'hb1,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb5,8'h24,8'hb5,8'hb5,8'hb5,8'h91,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'hb5,8'hb1},
	{8'hb5,8'hb1,8'h91,8'h91,8'h91,8'h91,8'h6d,8'hb5,8'h91,8'hb5,8'h20,8'hb1,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb5,8'h00,8'hb5,8'hb5,8'hb5,8'h91,8'hb5,8'hb5,8'h91,8'h91,8'hb5,8'hb5,8'h91,8'hb1,8'h91},
	{8'hb1,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb1,8'hb5,8'h64,8'hb1,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb5,8'h91,8'hb1,8'h91,8'h00,8'hb1,8'hb1,8'hb5,8'hb1,8'hb5,8'hb1,8'h91,8'h91,8'h91},
	{8'hd6,8'hb5,8'hb5,8'hb1,8'h91,8'h91,8'hb5,8'h91,8'h91,8'hb1,8'h64,8'hb1,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb1,8'hb1,8'hb5,8'hb5,8'hb5,8'h00,8'h91,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'h8d,8'hb1},
	{8'hb6,8'hb5,8'hb1,8'hb5,8'h91,8'hb5,8'hb5,8'hb1,8'hb5,8'hb5,8'h24,8'hd6,8'h91,8'h91,8'hd6,8'hb5,8'h91,8'hb1,8'hb5,8'hb5,8'hb5,8'h6c,8'h91,8'h91,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'h91,8'h91},
	{8'hd6,8'hb5,8'hb5,8'h91,8'h91,8'hb5,8'h91,8'hb5,8'h91,8'hb1,8'h24,8'hb5,8'h91,8'h91,8'h91,8'hb5,8'hb1,8'hb1,8'hb6,8'hb5,8'hb1,8'h24,8'hd6,8'h91,8'h91,8'hb5,8'hb5,8'h91,8'hb5,8'hb1,8'h6d,8'hb5},
	{8'hb5,8'h91,8'hb5,8'h91,8'hb5,8'h91,8'hb5,8'hb5,8'hb5,8'hb5,8'h24,8'hb5,8'h91,8'h91,8'hb5,8'h91,8'hb1,8'hb5,8'hb6,8'hd6,8'hb5,8'h24,8'hd6,8'h91,8'h91,8'hb1,8'hb5,8'h24,8'hb5,8'hb1,8'hfa,8'hd6},
	{8'hb5,8'hb1,8'hb1,8'hb1,8'hb5,8'h00,8'hb5,8'hb5,8'hb5,8'h91,8'h24,8'hb5,8'hb5,8'hb6,8'h6d,8'h6d,8'h91,8'hb5,8'h24,8'hb5,8'h91,8'h24,8'h00,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h91}},
};
    
    // LOGIC & MAP GENERATION
    // ---------------------------------------------------------------------------------

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGBout <= 8'h00;
            counter_Score <= 0;
            // Default Map (Empty)
            MazeBitMapMask <= '{default: 64'h0};
        end
        
        else if(newLevel) begin
            counter_Score <= 0; 
            
            // ========================= LEVEL 1 =========================
            // Objects 1-4 only. No 5, 6, 7.
            if (level_input == 1) begin
                 case (map_randomizer)
                  3'd0: MazeBitMapMask <= '{ // Map 1: The Jackpot (Rows of pure value)
                        {64'h0000000000000000}, 
                        {64'h4444444444444444}, // Row of BLUE DIAMONDS (320 pts total!)
                        {64'h0000000000000000}, 
                        {64'h3333333333333333}, // Row of RED DIAMONDS
                        {64'h0000000000000000}, 
                        {64'h1111111111111111}, // Row of GOLD
                        {64'h4444444444444444}, // Another Row of BLUE
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};

                    3'd1: MazeBitMapMask <= '{ // Map 2: Vertical Stripes (Easy aiming)
                        {64'h0000000000000000}, 
                        {64'h4040404040404040}, // Blue columns
                        {64'h3030303030303030}, // Red columns
                        {64'h4040404040404040}, 
                        {64'h3030303030303030}, 
                        {64'h1111111111111111}, // Floor of Gold
                        {64'h4444444444444444}, // Floor of Blue
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};

                    3'd2: MazeBitMapMask <= '{ // Map 3: The Big Block (Easy Hit)
                        {64'h0000000000000000}, 
                        {64'h0000444444000000}, // Center block of Blue
                        {64'h0000444444000000}, 
                        {64'h0000333333000000}, // Surrounded by Red
                        {64'h1111333333111111}, 
                        {64'h1111111111111111}, 
                        {64'h2000000000000002}, // Only 2 stones on edges
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};

                    3'd3: MazeBitMapMask <= '{ // Map 4: Checkerboard of Wealth
                        {64'h0000000000000000}, 
                        {64'h4343434343434343}, // Blue/Red alternating
                        {64'h3434343434343434}, 
                        {64'h4343434343434343}, 
                        {64'h1111111111111111}, 
                        {64'h4444444444444444}, 
                        {64'h0000000000000000}, 
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};

                    3'd4: MazeBitMapMask <= '{ // Map 5: The Pyramid
                        {64'h0000000000000000}, 
                        {64'h0000004400000000}, // Top: Blue
                        {64'h0000044440000000}, 
                        {64'h0000333333000000}, 
                        {64'h0004444444400000}, // More Blue
                        {64'h1111111111111111}, // Base: Gold
                        {64'h4444444444444444}, // Bonus Base
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};

                    default: MazeBitMapMask <= '{ // Map 6: Chaos (But good chaos)
                        {64'h0000000000000000}, 
                        {64'h4143414341434143}, // Mix of everything good
                        {64'h3414341434143414}, 
                        {64'h0000000000000000}, 
                        {64'h4444444444444444}, // Easy row
                        {64'h3333333333333333}, 
                        {64'h1111111111111111}, 
                        {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, 
                        {64'h0000000000000000}, {64'h0000000000000000}};
                 endcase
            end

            // =============================================================
            // LEVEL 2: Shields (7) appearing
            // =============================================================
            else if (level_input == 2) begin
                 case (map_randomizer)
                    3'd0: MazeBitMapMask <= '{ // Map 1: Shielded Rows
                        {64'h0000000000000000}, {64'h7777777777777777}, {64'h4444444444444444}, {64'h0000000000000000},
                        {64'h7777777777777777}, {64'h3333333333333333}, {64'h6060606060606060}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd1: MazeBitMapMask <= '{ // Map 2: The Bunker (7 surrounds 4)
                        {64'h0000000000000000}, {64'h7777777777777777}, {64'h4444333344443333}, {64'h7777777777777777},
                        {64'h0066006600660066}, {64'h1111111111111111}, {64'h4444444444444444}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd2: MazeBitMapMask <= '{ // Map 3: Pillars of Wealth
                        {64'h0000000000000000}, {64'h0707070707070707}, {64'h0404040404040404}, {64'h0707070707070707},
                        {64'h0404040404040404}, {64'h6161616161616161}, {64'h3333333333333333}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd3: MazeBitMapMask <= '{ // Map 4: Heavy Shielding
                        {64'h0000000000000000}, {64'h7744774477447744}, {64'h7733773377337733}, {64'h7744774477447744},
                        {64'h0000000000000000}, {64'h6161616161616161}, {64'h1111111111111111}, {64'h4444444444444444},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd4: MazeBitMapMask <= '{ // Map 5: Checker Shields
                        {64'h0000000000000000}, {64'h7474747474747474}, {64'h3737373737373737}, {64'h4747474747474747},
                        {64'h6060606060606060}, {64'h1111111111111111}, {64'h3333333333333333}, {64'h4444444444444444},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    default: MazeBitMapMask <= '{ // Map 6: Danger Zone
                        {64'h0000000000000000}, {64'h7777777777777777}, {64'h3344334433443344}, {64'h6666666666666666},
                        {64'h7777777777777777}, {64'h4444444444444444}, {64'h1111111111111111}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                 endcase
            end

            // =============================================================
            // LEVEL 3: All Objects. 5 (Strong) HIGH up.
            // =============================================================
            else begin 
                 case (map_randomizer)
                    3'd0: MazeBitMapMask <= '{ // Map 1: The Great Wall (Row of 5s)
                        {64'h0000000000000000}, {64'h5555555555555555}, {64'h0000000000000000}, {64'h7777777777777777},
                        {64'h4444444444444444}, {64'h6611661166116611}, {64'h3333333333333333}, {64'h4444444444444444},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd1: MazeBitMapMask <= '{ // Map 2: Layered Defense
                        {64'h0000000000000000}, {64'h5050505050505050}, {64'h7777777777777777}, {64'h4444444444444444},
                        {64'h3333333333333333}, {64'h6161616161616161}, {64'h7777777777777777}, {64'h4444444444444444},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd2: MazeBitMapMask <= '{ // Map 3: The Vault (5s enclosing 4s)
                        {64'h0000000000000000}, {64'h5555555555555555}, {64'h5444444444444445}, {64'h5444444444444445},
                        {64'h5444444444444445}, {64'h6000000000000006}, {64'h1111111111111111}, {64'h3333333333333333},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd3: MazeBitMapMask <= '{ // Map 4: Hard Block
                        {64'h0000000000000000}, {64'h5550000000000555}, {64'h7777777777777777}, {64'h4444444444444444},
                        {64'h3333333333333333}, {64'h7777777777777777}, {64'h4444444444444444}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    3'd4: MazeBitMapMask <= '{ // Map 5: High Stakes (Lots of 6s and 4s)
                        {64'h0000000000000000}, {64'h5050505050505050}, {64'h0000000000000000}, {64'h7777777777777777},
                        {64'h4444444444444444}, {64'h6464646464646464}, {64'h1111111111111111}, {64'h3333333333333333},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                    default: MazeBitMapMask <= '{ // Map 6: Chaos
                        {64'h0000000000000000}, {64'h5005005005005005}, {64'h0000000000000000}, {64'h7777777777777777},
                        {64'h4444444444444444}, {64'h6666666666666666}, {64'h3333333333333333}, {64'h1111111111111111},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000},
                        {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}, {64'h0000000000000000}};
                 endcase
            end
        end
        else begin
            RGBout <= TRANSPARENT_ENCODING; 
            Is_Rock <= 0;
            // -------------------------------------------------------------------------
            // COLLISION LOGIC 
            // -------------------------------------------------------------------------
            if (collision_bomb_object) begin
                case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                    4'd1: begin // Gold
                            counter_Score <= counter_Score + GOLD_VALUE; 
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                          end
                    4'd2: begin // Stone
                            counter_Score <= counter_Score + STONE_VALUE; 
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                          end
                    4'd3: begin // Red Diamond
                            counter_Score <= counter_Score + REDDIAMOND_VALUE; 
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                          end
                    4'd4: begin // Blue Diamond
                            counter_Score <= counter_Score + BLUEDIAMOND_VALUE;
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                          end
                    4'd5: begin // Strong Stone (5) -> Becomes Weak Stone (7)
                            counter_Score <= counter_Score + STONE_VALUE;
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'd9; 
                          end
                    4'd6: begin // Black Hole
                            counter_Score <= counter_Score + BLACK_HOLE;
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                          end
                    4'd7: begin // Weak Stone (7) -> Disappears
                            counter_Score <= counter_Score + STONE_VALUE;
                            MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
								  end 
						  4'd9: begin
                          end
                    default: counter_Score <= counter_Score;
                endcase
            end
                         
            // -------------------------------------------------------------------------
            // DRAWING LOGIC 
            // -------------------------------------------------------------------------
            if (InsideRectangle) begin 
				    if ((MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 4'd9) && !collision_bomb_object) begin
                     MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'd7;
							end
                case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                    4'd0: begin RGBout <= TRANSPARENT_ENCODING; Is_Rock <= 0; end
                    4'd1: begin RGBout <= object_colors[1][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0;  end 
                    4'd2: begin RGBout <= object_colors[2][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0; end
                    4'd3: begin RGBout <= object_colors[3][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0; end
                    4'd4: begin RGBout <= object_colors[4][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0; end
                    4'd5: begin RGBout <= object_colors[5][offsetY_LSB][offsetX_LSB]; Is_Rock <= 1; end
                    4'd6: begin RGBout <= object_colors[6][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0; end
                    4'd7: begin RGBout <= object_colors[7][offsetY_LSB][offsetX_LSB]; Is_Rock <= 1;  end
						  4'd9: begin RGBout <= object_colors[7][offsetY_LSB][offsetX_LSB]; Is_Rock <= 0;  end
                    default: begin RGBout <= TRANSPARENT_ENCODING; Is_Rock <= 0; end
                endcase
            end 
        end 
    end

    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING);

endmodule