// HartsMatrixBitMap File 
// A two level bitmap displaying hearts/objects on the screen Feb 2025 
// (c) Technion IIT, Department of Electrical Engineering 2025 

module MazeMatrixBitMap ( 
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] offsetX, // offset from top left position 
    input  logic [10:0] offsetY,
    input  logic        InsideRectangle, // input that the pixel is within a bracket 
    input  logic        collision_bomb_object,
	 input  logic        MazeReset,
	 input  logic [1:0]  level_input,      // 1, 2, 3
    input  logic [2:0]  map_randomizer,   // 0-5
	 input  logic [1:0]  ExplosionState,
	 input  logic        gemDetectorSignal,
	 input  logic        luckyCharm,
	 

    output logic        drawingRequest,
    output logic [7:0]  RGBout,        
	 output logic [9:0]  counter_Score,
	 output logic Is_Rock,
	 output logic is_treasure
);

    localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

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
	 //3 pinkdiamond
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
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hb0,8'hd0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf5,8'hf8,8'hf8,8'hd0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hb0,8'hb0,8'hb0,8'hf4,8'hfd,8'hfd,8'hfd,8'hf5,8'hb0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hb0,8'hb0,8'hb0,8'hfc,8'hfd,8'hff,8'hff,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfc,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd0,8'hd0,8'hb0,8'hd0,8'hf8,8'hf8,8'hf8,8'hfd,8'hff,8'hff,8'hff,8'hfd,8'hfd,8'hfd,8'hfe,8'hfe,8'hff,8'hfd,8'hfd,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf5,8'hf4,8'hf4,8'hfc,8'hfd,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfe,8'hfd,8'hfe,8'hfd,8'hf8,8'hd0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hac,8'hfe,8'hfc,8'hfe,8'hfe,8'hff,8'hfd,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hf8,8'hf8,8'hf8,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf4,8'hfd,8'hff,8'hfd,8'hfd,8'hfd,8'hfe,8'hfd,8'hfd,8'hfd,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hff,8'hfe,8'hfd,8'hf8,8'hf5,8'h8c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf4,8'hfc,8'hfd,8'hff,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfe,8'hff,8'hfe,8'hfe,8'hfd,8'hd0,8'hf8,8'hf8,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf5,8'hf8,8'hf8,8'hfd,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hf8,8'hf8,8'hd0,8'hfd,8'hb0,8'h8c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf4,8'hfd,8'hf8,8'hf8,8'hfd,8'hfe,8'hfd,8'hfd,8'hfd,8'hfe,8'hfe,8'hfe,8'hfd,8'hf8,8'hfc,8'hd4,8'hd0,8'hd0,8'hf8,8'hf4,8'hf8,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf8,8'hfd,8'hfd,8'hfc,8'hfc,8'hfe,8'hff,8'hff,8'hfd,8'hf8,8'hf8,8'hf8,8'hf8,8'hf5,8'hf8,8'hd5,8'hf8,8'hf8,8'hfd,8'hf8,8'hf4,8'hf4,8'h8c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf8,8'hfc,8'hfc,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hf8,8'hf8,8'hd0,8'hd0,8'hd0,8'hf5,8'hfc,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hd0,8'hf5,8'hfc,8'hfd,8'hfd,8'hfd,8'hf5,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf4,8'hfd,8'hf4,8'hf4,8'hf8,8'hfc,8'hd0,8'hd0,8'hf4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hac,8'hf8,8'hf5,8'hf8,8'hfd,8'hfd,8'hfd,8'hf8,8'hd0,8'hfd,8'hf8,8'hf4,8'hd0,8'hf8,8'hf4,8'hf8,8'hd0,8'hd0,8'hf4,8'h64,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hac,8'hf5,8'hf8,8'hd0,8'hfc,8'hfd,8'hf8,8'hd0,8'hf8,8'hd0,8'hd0,8'hd0,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hf5,8'hf8,8'hfc,8'hfc,8'hf4,8'hd0,8'hd4,8'h8c,8'h64,8'h8c,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hb0,8'hf8,8'hf8,8'hd0,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hac,8'h8c,8'h8c,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h8c,8'h8c,8'h8c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h8c,8'h8c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h24,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hb1,8'hb1,8'h91,8'hd5,8'hb1,8'hb5,8'hd5,8'hb5,8'hb5,8'h90,8'h6c,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h90,8'hb1,8'hb5,8'hd5,8'hd5,8'hd5,8'hb5,8'hd5,8'hd5,8'hb1,8'hb1,8'hd5,8'hb5,8'hb1,8'h6c,8'h8c,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hb1,8'hb1,8'hb5,8'hb1,8'hd5,8'hd5,8'hb5,8'h90,8'h8c,8'hd5,8'hb5,8'h91,8'hb1,8'hb5,8'h6c,8'h91,8'h8c,8'h8d,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hb1,8'hb1,8'hb5,8'hb1,8'hd5,8'hd5,8'hb5,8'h8c,8'hb1,8'hb5,8'hb5,8'hb1,8'hb1,8'hb5,8'h6c,8'hb1,8'h91,8'h91,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hd5,8'hd5,8'hb1,8'hb5,8'h64,8'h6c,8'h90,8'hd5,8'hb5,8'hb5,8'h91,8'h91,8'h91,8'h91,8'hb1,8'h91,8'h91,8'h91,8'h8d,8'h8c,8'h24,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hb5,8'h90,8'h8c,8'h64,8'h64,8'hb1,8'h91,8'h91,8'h91,8'hb1,8'h91,8'hb1,8'hb1,8'hb1,8'hb1,8'h8c,8'h91,8'hd5,8'hb5,8'h91,8'h8d,8'h8c,8'h24,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hb1,8'hb1,8'h8c,8'h6c,8'h91,8'h6c,8'h91,8'hb1,8'h90,8'hb1,8'hb1,8'h91,8'hb1,8'h91,8'hb0,8'hb5,8'h6c,8'h91,8'h90,8'h64,8'h8c,8'h91,8'h6c,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h8c,8'h8c,8'h91,8'hb5,8'h8c,8'h6c,8'h91,8'h64,8'h91,8'h91,8'hb1,8'hb1,8'hb5,8'h91,8'h90,8'h90,8'hb1,8'hb1,8'h64,8'h91,8'h91,8'h64,8'h8c,8'h8c,8'h6c,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h64,8'h64,8'h90,8'h90,8'hb1,8'hb5,8'h6c,8'hb1,8'h64,8'h8c,8'h90,8'hb1,8'h91,8'hb1,8'hb1,8'hb1,8'hb1,8'h8c,8'hb1,8'h6c,8'h6c,8'h64,8'h8c,8'h8c,8'h8c,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h6c,8'h8c,8'h90,8'h90,8'h90,8'hb1,8'hb1,8'h6c,8'hb1,8'h91,8'hb1,8'h91,8'hb1,8'h8c,8'hb1,8'hb1,8'hb1,8'hb1,8'h64,8'h6c,8'h6c,8'h8c,8'h6c,8'h6c,8'h8c,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h24,8'h24,8'h6c,8'h24,8'h91,8'hb1,8'hb1,8'h91,8'h64,8'h8c,8'h6c,8'hb1,8'h91,8'h91,8'h64,8'hb1,8'h91,8'h64,8'h6c,8'h8c,8'h6c,8'h8c,8'h8c,8'h90,8'h64,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h6d,8'h6d,8'h6c,8'h64,8'h6c,8'h8c,8'h91,8'h91,8'h8c,8'h8c,8'h8c,8'h91,8'h91,8'h8c,8'h6c,8'h91,8'h8c,8'h64,8'h6c,8'h8c,8'h64,8'h8c,8'h8c,8'h8d,8'h91,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h6c,8'h64,8'h64,8'h90,8'h6c,8'hb1,8'h90,8'h8c,8'h8c,8'h6c,8'h90,8'h8c,8'h24,8'h64,8'h64,8'h6c,8'h8c,8'h8c,8'h6c,8'h24,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h24,8'h24,8'h64,8'h8c,8'h64,8'h6c,8'h24,8'h6c,8'h64,8'h6c,8'h8c,8'h6c,8'h64,8'h6c,8'h8c,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h24,8'h24,8'h24,8'h64,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha1,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'h81,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hff,8'h80,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hf2,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h85,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'hfa,8'hff,8'hfb,8'hf6,8'hf7,8'hf7,8'hf7,8'hf6,8'hf2,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'ha1,8'hf7,8'hf7,8'hf7,8'hf7,8'hfb,8'hf6,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'h81,8'hf6,8'hf7,8'hf7,8'hf7,8'hf7,8'hf2,8'h81,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'h81,8'hf6,8'hf6,8'hf6,8'hf6,8'hf6,8'hf2,8'h81,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'h81,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h81,8'hfb,8'hf2,8'hf2,8'hf2,8'hf2,8'h81,8'hf2,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'ha1,8'hc5,8'hc5,8'hc5,8'hc5,8'hf2,8'h81,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'ha1,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'h81,8'hf6,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'hed,8'h81,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hf2,8'hf2,8'hf2,8'hf2,8'h81,8'hf6,8'hee,8'hee,8'hee,8'hee,8'hee,8'hee,8'hed,8'h81,8'hc5,8'hc5,8'hc5,8'hed,8'hee,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hfb,8'hf2,8'hf2,8'hf2,8'hf2,8'h81,8'hee,8'hee,8'hee,8'hee,8'hf2,8'hf2,8'h81,8'hc5,8'hc5,8'hc5,8'hc5,8'hee,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha5,8'hf7,8'hf2,8'hf2,8'hf2,8'ha1,8'hf2,8'hf2,8'hee,8'hf2,8'h81,8'hcd,8'hc5,8'hc5,8'hee,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hf2,8'hf2,8'hf2,8'h81,8'hf2,8'hf2,8'hf2,8'hee,8'ha1,8'hc5,8'hc5,8'hc5,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hf2,8'hf2,8'hf2,8'hee,8'hf2,8'hee,8'hf2,8'hc5,8'hc5,8'hc5,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h81,8'hfb,8'hf2,8'hf2,8'hf6,8'hf2,8'hf2,8'hed,8'hc5,8'hc5,8'hee,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha1,8'hf6,8'ha1,8'hf6,8'hee,8'h81,8'hee,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha1,8'h81,8'hf6,8'hee,8'h81,8'ha1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'h81,8'h81,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha5,8'h81,8'h81,8'h80,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'hdf,8'hdf,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h37,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hdf,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'hff,8'h7f,8'h9f,8'hff,8'h7b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3f,8'h37,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'h7f,8'h00,8'hff,8'h9f,8'h9f,8'h9f,8'h9f,8'hdf,8'h00,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hdf,8'h9f,8'h9f,8'h9f,8'h7f,8'h9f,8'h00,8'hdf,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'hdf,8'h00,8'h3b,8'h3b,8'h7f,8'h3f,8'h3f,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'hdf,8'h9f,8'h7f,8'h7f,8'h9f,8'h9f,8'h00,8'hdf,8'h7f,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'h9f,8'h20,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h37,8'h37,8'h37,8'h37,8'h37,8'h33,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h9f,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h7f,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h37,8'h00,8'h37,8'h37,8'h37,8'h33,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h7f,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h37,8'h00,8'h37,8'h37,8'h37,8'h37,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h9f,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h7f,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h37,8'h00,8'h37,8'h37,8'h37,8'h37,8'h37,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h7f,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h37,8'h37,8'h37,8'h37,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h04,8'h7f,8'h3b,8'h3b,8'h3b,8'h00,8'h3b,8'h3b,8'h3b,8'h3b,8'h05,8'h32,8'h37,8'h37,8'h37,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h3b,8'h3b,8'h3b,8'h00,8'h3b,8'h3b,8'h3b,8'h3b,8'h00,8'h37,8'h37,8'h37,8'h05,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h9f,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h3b,8'h37,8'h37,8'h37,8'h37,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h7f,8'h37,8'h3b,8'h7f,8'h3b,8'h3b,8'h32,8'h37,8'h37,8'h37,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h7f,8'h00,8'h7f,8'h3b,8'h00,8'h37,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h7f,8'h37,8'h00,8'h05,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h9f,8'h00,8'h24,8'h37,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h04,8'h24,8'h6d,8'h25,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h25,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h6d,8'h24,8'h00,8'h24,8'h24,8'h24,8'h65,8'h6d,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h6d,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h6d,8'h24,8'h24,8'h6d,8'h25,8'h6d,8'h6d,8'h25,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h25,8'h25,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h6d,8'h6d,8'h25,8'h25,8'h24,8'h6d,8'h65,8'h25,8'h25,8'h6d,8'h00,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h6d,8'h24,8'h24,8'h20,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h00,8'h00,8'h24,8'h24,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h25,8'h24,8'h20,8'h24,8'h6d,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h24,8'h6d,8'h24,8'h24,8'h00,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h25,8'h24,8'h24,8'h6d,8'h25,8'h65,8'h24,8'h24,8'h00,8'h04,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h20,8'h24,8'h24,8'h24,8'h24,8'h2d,8'h24,8'h20,8'h24,8'h6d,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h25,8'h24,8'h00,8'h6d,8'h24,8'h24,8'h00,8'h24,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h00,8'h6d,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h00,8'h24,8'h24,8'h6d,8'h24,8'h24,8'h24,8'h24,8'h24,8'h04,8'h00,8'h6d,8'h6d,8'h00,8'h00,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h00,8'h20,8'h24,8'h65,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h24,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h00,8'h24,8'h24,8'h00,8'h24,8'h24,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h04,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h24,8'h00,8'h24,8'h00,8'h24,8'h20,8'h6d,8'h24,8'h24,8'h6d,8'h00,8'h00,8'h24,8'h24,8'h00,8'h00,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h00,8'h24,8'h00,8'h00,8'h24,8'h24,8'h00,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h00,8'h24,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h00,8'h20,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
		
		

	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h91,8'hb6,8'hfe,8'hb6,8'h91,8'h6d,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6c,8'hb6,8'hfa,8'h00,8'hda,8'hb6,8'hda,8'hd6,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'h91,8'hb6,8'hda,8'hb6,8'h91,8'hb6,8'hb6,8'hb5,8'hda,8'hd6,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'hb6,8'hda,8'h91,8'hb5,8'hda,8'h00,8'hb6,8'h91,8'hb6,8'hda,8'hb6,8'h91,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb1,8'hff,8'hda,8'h00,8'h00,8'h00,8'hfa,8'h00,8'hda,8'hda,8'hb6,8'h91,8'hb1,8'hda,8'h00,8'h91,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb5,8'hff,8'hff,8'hda,8'hff,8'h00,8'h00,8'hda,8'hda,8'hfe,8'hfe,8'hfe,8'hb1,8'h91,8'h00,8'h00,8'h91,8'h6d,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hd6,8'hff,8'hda,8'hda,8'hda,8'hda,8'h00,8'hda,8'hda,8'hda,8'hfe,8'h91,8'hda,8'h00,8'h00,8'h91,8'h91,8'h91,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfe,8'hda,8'hb6,8'h91,8'hb5,8'hff,8'hff,8'hda,8'hff,8'hff,8'hda,8'hb6,8'h00,8'h00,8'h00,8'h91,8'hd6,8'h91,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hb6,8'hda,8'hb5,8'h91,8'h00,8'hff,8'hb6,8'hda,8'h00,8'hb6,8'hb6,8'h00,8'h00,8'hfa,8'hb6,8'hda,8'h91,8'hb6,8'h91,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hb6,8'hb1,8'hb6,8'hb5,8'hb6,8'h00,8'hb6,8'hd6,8'hb6,8'h00,8'h00,8'h00,8'hda,8'hda,8'hd6,8'hb6,8'hb5,8'h91,8'h91,8'h91,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hb6,8'h91,8'h91,8'hb1,8'hb1,8'hb5,8'hb6,8'hda,8'hb6,8'h00,8'h00,8'hfe,8'hb5,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h91,8'hda,8'hb6,8'h91,8'hda,8'hb1,8'h91,8'h91,8'h00,8'h00,8'h00,8'hd6,8'hb6,8'hb6,8'hb6,8'h8d,8'hd6,8'h91,8'h91,8'h91,8'h2c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h91,8'hb6,8'h6d,8'hb6,8'hb6,8'hda,8'h00,8'hb5,8'h91,8'h91,8'h00,8'h91,8'h91,8'hd6,8'hb6,8'h6d,8'h00,8'hb1,8'hb5,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hb6,8'h91,8'h91,8'hb6,8'hda,8'h00,8'h00,8'h91,8'h91,8'h91,8'h00,8'hb1,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h00,8'h00,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb6,8'h91,8'hb6,8'hb6,8'hb1,8'h00,8'h91,8'h8d,8'h91,8'h00,8'hb6,8'h00,8'h00,8'h91,8'h6d,8'h91,8'h91,8'h6d,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb1,8'hb6,8'hb5,8'h91,8'h00,8'h00,8'hb1,8'h91,8'hb6,8'hb6,8'hb5,8'hb6,8'h6d,8'h00,8'h91,8'h91,8'h6d,8'h71,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h91,8'h00,8'h6d,8'h00,8'hb1,8'h91,8'hb6,8'h8d,8'hb5,8'h6d,8'h6d,8'h91,8'h91,8'h6d,8'h91,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h91,8'h91,8'h91,8'h6d,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h6d,8'h6d,8'h8d,8'h91,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'h8d,8'h91,8'h91,8'h91,8'h91,8'h8d,8'h8d,8'h6d,8'h91,8'h6c,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h6d,8'h91,8'h91,8'h6d,8'h24,8'h6c,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
};
    
    // LOGIC & MAP GENERATION
    // ---------------------------------------------------------------------------------

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGBout <= 8'h00;
            counter_Score <= 0;
				Is_Rock <= 1'b0;
            // Default Map (Empty)
            MazeBitMapMask <= '{default: 64'h0};
        end
        
        else if(MazeReset) begin
            counter_Score <= 0; 
           
            // =============================================================
            // LEVEL 1: Objects 1,2,3,4. 
            // Target: 150.
            // =============================================================
            if (level_input == 1) begin
                 case (map_randomizer)
                  3'd0: MazeBitMapMask <= '{ 
                        {64'h0011102203010340}, {64'h0}, 
                        {64'h4040040003400404}, 
                        {64'h0000011110000000},
                        {64'h0200204042000200}, 
                        {64'h4440000000444000},
                        {64'h4003001100030004}, 
                        {64'h0200440004400200},
                        {64'h0022222222222000}, 
                        {64'h1111111411114111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};      

                  3'd1: MazeBitMapMask <= '{ 
                        {64'h0001110022031342},
							   {64'h4402222222044400},	
                        {64'h0040004000004000},
                        {64'h0000002002000000}, 
                        {64'h4000301110300040}, 
                        {64'h0000002002000000}, 
                        {64'h0330001110003300}, 
                        {64'h2000400000400020}, 
                        {64'h0000000000000000}, 
                        {64'h1111111111111111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                  3'd2: MazeBitMapMask <= '{ 
                        {64'h4044000000014440},
								{64'h4033002220000040},
                        {64'h4003000000033040}, 
                        {64'h4004022200004040}, 
                        {64'h4000011100000040}, 
                        {64'h4244003004400240}, 
                        {64'h0220102000102200}, 
                        {64'h0022104000102200}, 
                        {64'h0002222222220000}, 
                        {64'h0000111111110000}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                  3'd3: MazeBitMapMask <= '{ 
                        {64'h4030030030001040},
								{64'h1001100101010010},
                        {64'h4020402040204020}, 
                        {64'h0020102000201020},
                        {64'h0020302030200020}, 
                        {64'h0023332333203320},
                        {64'h0020302030200020},
                        {64'h0020002000200020},
                        {64'h0020402040204420}, 
                        {64'h1111111111111111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                  3'd4: MazeBitMapMask <= '{ 
                        {64'h0440000000000010},
								{64'h0000343000000343},
                        {64'h0011040000110444},
                        {64'h0022222222222200}, 
                        {64'h0020044004400200}, 
                        {64'h0020033003300200}, 
                        {64'h0020001111100200},
                        {64'h3322220000222240}, 
                        {64'h0033000220003300}, 
                        {64'h1111111441111111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                  default: MazeBitMapMask <= '{ 
                        {64'h3300000330000033},
								{64'h2202200000000000},
                        {64'h1100440000440011}, 
                        {64'h0022000330002200}, 
                        {64'h4000033000440003},
                        {64'h4003000440003004},
                        {64'h0100010000100100}, 
                        {64'h0000003333000000},
                        {64'h0022330000033200}, 
                        {64'h1111111111111111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};
                 endcase
            end

            // =============================================================
            // LEVEL 2: Objects 1,3,4,6,7. 
            // Target: 200.
            // =============================================================
            else if (level_input == 2) begin
                 case (map_randomizer)
                    3'd0: MazeBitMapMask <= '{ 
                        {64'h1100040040001010},
								{64'h1301000100010003},
                        {64'h4400440040440100}, 
                        {64'h0011043330000104}, 
                        {64'h6600000400006600}, 
                        {64'h7777000004007777}, 
                        {64'h0000007700000000}, 
                        {64'h3330400000004333}, 
                        {64'h4040333333330404}, 
                        {64'h1311111111131111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd1: MazeBitMapMask <= '{ 
                        {64'h0000003330000000},
								{64'h1000004440000110},
                        {64'h4114000000004114}, 
                        {64'h0000001111000000}, 
                        {64'h1100000000000011}, 
                        {64'h0066007777006600}, 
                        {64'h0000006666000000}, 
                        {64'h3040004040330030}, 
                        {64'h0000000000000000}, 
                        {64'h1133113333113311}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd2: MazeBitMapMask <= '{ 
                        {64'h1000300000300014},
								{64'h1001001000100014},
                        {64'h4040406666404000},
                        {64'h3010031010003300}, 
                        {64'h0000000000000000}, 
                        {64'h7007007070700007}, 
                        {64'h0000060600060000}, 
                        {64'h0003030300000300}, 
                        {64'h4040400000404040},
                        {64'h1111111111111111}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd3: MazeBitMapMask <= '{ 
                        {64'h4030010010003044},
								{64'h0000600000600000},
                        {64'h7700000440000077}, 
                        {64'h0000070000070000}, 
                        {64'h4400000000000044}, 
                        {64'h0400330033304000},
                        {64'h0040040000400400}, 
                        {64'h0001010000100000}, 
                        {64'h7700000000000077}, 
                        {64'h0003333333311000}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd4: MazeBitMapMask <= '{ 
                        {64'h0030000000030000},
								{64'h0700007770000700},
                        {64'h0000100000000004}, 
                        {64'h0401040104010401}, 
                        {64'h1040010000101044}, 
                        {64'h0006000000600000}, 
                        {64'h7070707070707070}, 
                        {64'h0000000000000000}, 
                        {64'h4040040040400040}, 
                        {64'h3113311333311333}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    default: MazeBitMapMask <= '{ 
                        {64'h1340000003000041},
								{64'h0000000606000000},
                        {64'h0077000333007700},
                        {64'h4000000110000004}, 
                        {64'h0033000000003300}, 
                        {64'h4400440000440044}, 
                        {64'h0000000111000000}, 
                        {64'h1140000000000011}, 
                        {64'h0000007777000000},
                        {64'h3330100000003333}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};
                 endcase
            end

            // =============================================================
            // LEVEL 3: Objects 1,3,4,5,6,7. 
            // Target: 250
            // =============================================================
            else begin 
                 case (map_randomizer)
                    3'd0: MazeBitMapMask <= '{
                        {64'h0400400000040400},
								{64'h3330000500000333},
                        {64'h0000410004440000},
                        {64'h0000001110000000}, 
                        {64'h0010000000001000}, 
                        {64'h5000005550000005}, 
                        {64'h0055000000055000}, 
                        {64'h4000004440000004}, 
                        {64'h0101016666000100},
                        {64'h4441333333334344}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd1: MazeBitMapMask <= '{
                        {64'h0000000110000000},
								{64'h0004400000044000},
                        {64'h5500001110000055},
                        {64'h0005500440055000}, 
                        {64'h0000000000000000}, 
                        {64'h0044440000444400}, 
                        {64'h0000001111000000}, 
                        {64'h0330000000000030}, 
                        {64'h0111005555001010},
                        {64'h3333400000003333}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd2: MazeBitMapMask <= '{ 
                        {64'h0000110000011000},
								{64'h0000000500000050},
                        {64'h0044010000104000}, 
                        {64'h0000000000000000}, 
                        {64'h0011005500011000}, 
                        {64'h5000000000000005},
                        {64'h0000004400000000}, 
                        {64'h4066000000066004}, 
                        {64'h0000006666000000},
                        {64'h4414411441114144}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd3: MazeBitMapMask <= '{ 
                        {64'h4000000000040000},
								{64'h0310000303004040},
                        {64'h0000400000300004}, 
                        {64'h0050006506000500}, 
                        {64'h0060005005000600},
                        {64'h0500100000050101}, 
                        {64'h0000004004000000}, 
                        {64'h4443636163641114}, 
                        {64'h1010001000000100}, 
                        {64'h3333333333333333}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    3'd4: MazeBitMapMask <= '{
                        {64'h0000000330000001},
								{64'h0003300000003300},
                        {64'h4010001111001010},
                        {64'h0000001010000000}, 
                        {64'h0550000000000550}, 
                        {64'h0000600550060000}, 
                        {64'h4000000000000400}, 
                        {64'h0070043343100007}, 
                        {64'h5000010440010005},
                        {64'h0041333331334000},
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};

                    default: MazeBitMapMask <= '{
                        {64'h0440000000004400},
								{64'h0000000606000000},
                        {64'h5500400555500550},
                        {64'h0000000000000000},
                        {64'h0440100101010440}, 
                        {64'h3300004444000330},
                        {64'h1000000000000010}, 
                        {64'h4000070707070040}, 
                        {64'h6600000000000066},
                        {64'h4411443113441144}, 
                        {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}, {64'h0}};
                 endcase
            end
        end
        else begin
            RGBout <= TRANSPARENT_ENCODING; 
				Is_Rock <= 1'b0;
				is_treasure <= 1'b0;
            // -------------------------------------------------------------------------
            // COLLISION LOGIC 
            // -------------------------------------------------------------------------
           
            // -------------------------------------------------------------------------
            if (collision_bomb_object) begin
                case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                    
                    // --- CASE 1: GOLD ---
                    4'd1: begin 
                        if (gemDetectorSignal == 1'b1) begin
                            if (luckyCharm) 
                                counter_Score <= counter_Score + BLUEDIAMOND_VALUE + (BLUEDIAMOND_VALUE / 5); // 20 + 4 = 24
                            else 
                                counter_Score <= counter_Score + BLUEDIAMOND_VALUE; // 20
                        end
                        else begin
                            if (luckyCharm) 
                                counter_Score <= counter_Score + GOLD_VALUE + (GOLD_VALUE / 5); // 5 + 1 = 6
                            else 
                                counter_Score <= counter_Score + GOLD_VALUE; // 5
                        end
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                    end

                    // --- CASE 2: STONE ---
                    4'd2: begin 
                        counter_Score <= counter_Score + STONE_VALUE; 
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                    end

                    // --- CASE 3: RED DIAMOND ---
                    4'd3: begin 
                        if (luckyCharm) 
                            counter_Score <= counter_Score + REDDIAMOND_VALUE + (REDDIAMOND_VALUE / 5); // 10 + 2 = 12
                        else 
                            counter_Score <= counter_Score + REDDIAMOND_VALUE; // 10
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                    end

                    // --- CASE 4: BLUE DIAMOND ---
                    4'd4: begin 
                        if (luckyCharm) 
                            counter_Score <= counter_Score + BLUEDIAMOND_VALUE + (BLUEDIAMOND_VALUE / 5); // 20 + 4 = 24
                        else 
                            counter_Score <= counter_Score + BLUEDIAMOND_VALUE; // 20
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                    end

                    // --- CASE 5: STRONG STONE ---
                    4'd5: begin 
                        counter_Score <= counter_Score + STONE_VALUE;
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'd9;
                    end

                    // --- CASE 6: BLACK HOLE ---
                    4'd6: begin 
                        if (counter_Score >= 10) begin
                             counter_Score <= counter_Score + BLACK_HOLE; 
                        end
                        else begin
                             counter_Score <= 0;
                        end
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0; 
                    end

                    // --- CASE 7: WEAK STONE ---
                    4'd7: begin 
                        counter_Score <= counter_Score + STONE_VALUE;
                        MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'h0;
                    end 
						  //--- CASE 9: immune stone- midstate---
                    4'd9: begin
                    end

                    default: begin 
                        counter_Score <= counter_Score;
                    end
               endcase
            end 
  

            // -------------------------------------------------------------------------
            // DRAWING OBJECTS LOGIC 
            // -------------------------------------------------------------------------  
				
            if (InsideRectangle) begin 
				    if ((MazeBitMapMask[offsetY_MSB][offsetX_MSB] == 4'd9) && (ExplosionState == 2'b00)) begin
                     MazeBitMapMask[offsetY_MSB][offsetX_MSB] <= 4'd7;
							end
                case (MazeBitMapMask[offsetY_MSB][offsetX_MSB])
                    4'd0: begin 
								RGBout <= TRANSPARENT_ENCODING; 
						  end
                    4'd1: begin 
						        if (gemDetectorSignal == 1'b1) begin
									   RGBout <= object_colors[4][offsetY_LSB][offsetX_LSB]; 
									end
								  else begin
								      RGBout <= object_colors[1][offsetY_LSB][offsetX_LSB]; 
									end
								  is_treasure <= 1'b1;
								  end
                    4'd2: begin 
								RGBout <= object_colors[2][offsetY_LSB][offsetX_LSB];
						  end
                    4'd3: begin 
								RGBout <= object_colors[3][offsetY_LSB][offsetX_LSB];
								is_treasure <= 1'b1;
						  end
                    4'd4: begin 
								RGBout <= object_colors[4][offsetY_LSB][offsetX_LSB];
								is_treasure <= 1'b1;
						  end
                    4'd5: begin 
								RGBout <= object_colors[5][offsetY_LSB][offsetX_LSB];
								Is_Rock <= 1'b1; 
						  end
                    4'd6: begin 
								RGBout <= object_colors[6][offsetY_LSB][offsetX_LSB]; 
						  end
                    4'd7: begin 
								RGBout <= object_colors[7][offsetY_LSB][offsetX_LSB];
								Is_Rock <= 1'b1; 
						  end
						  4'd9: begin 
								RGBout <= object_colors[7][offsetY_LSB][offsetX_LSB];
								Is_Rock <= 1'b1; 
						  end
                    default: begin 
								RGBout <= TRANSPARENT_ENCODING;
						  end
                endcase
            end
			end	
    end

    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING);
endmodule