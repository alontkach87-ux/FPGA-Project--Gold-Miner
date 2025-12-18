module smallBombBitMap (	
    input	logic	clk,
    input	logic	resetN,
    input   logic	[10:0] offsetX, 
    input   logic	[10:0] offsetY,
    input	logic	InsideRectangle,
    input   logic   [8:0] Angle,    // Connected to smallBomb_move
	 input   logic [1:0] ExplosionState,
	 input   logic aimingFlag,
 
    output	logic	drawingRequest,
    output	logic	[7:0] RGBout,
    output  logic	[2:0] HitEdgeCode 
);

    // --- Dimensions ---
    localparam int OBJECT_HEIGHT_Y = 32;
    localparam int OBJECT_WIDTH_X  = 32;
	 localparam int CENTER_Y = 16;
	 localparam int CENTER_X = 16;
    localparam logic [7:0] TRANSPARENT = 8'hFF;

    // --- Coordinate Calculations ---
    logic [10:0] HitCodeX;
    logic [10:0] HitCodeY;
    assign HitCodeX = offsetX >> 1; 
    assign HitCodeY = offsetY >> 1;

    
    logic [0:31] [0:31] [7:0] bomb_sprite = {{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hb6,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h71,8'h6d,8'h91,8'hff,8'h6d,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h04,8'h24,8'h91,8'hba,8'hff,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h24,8'h6d,8'h91,8'h6d,8'h24,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h04,8'h24,8'h24,8'h6d,8'h6d,8'h24,8'h2d,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h04,8'h04,8'h2d,8'h6d,8'h6d,8'h2d,8'h6d,8'h24,8'h04,8'h91,8'hff,8'hfe,8'hf8,8'hff,8'hff,8'hff,8'hdf,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h04,8'h04,8'h24,8'h24,8'h2d,8'h24,8'h24,8'h00,8'h6d,8'hff,8'h92,8'hfc,8'hfc,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h04,8'h04,8'h04,8'h04,8'h00,8'h00,8'h8d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2d,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h04,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};
   
	logic [0:31] [0:31] [7:0] explosion_fire = { 
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hff,8'hff,8'hff,8'hfa,8'hff,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hde,8'h91,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hf9,8'hfa,8'hfe,8'hfa,8'hfe,8'hff,8'hf9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd5,8'hfe,8'hda,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfa,8'hf5,8'hf9,8'hfe,8'hf9,8'hf9,8'hfd,8'hfe,8'hff,8'hda,8'hff,8'hda,8'hff,8'hb6,8'h6d,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hfe,8'hda,8'hff,8'hff,8'hff,8'hfe,8'hf9,8'hfa,8'hf5,8'hf4,8'hfc,8'hf0,8'hfd,8'hf9,8'hfe,8'hb5,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hde,8'hda,8'hff,8'hff,8'hff,8'hfe,8'hf9,8'hf5,8'hf0,8'hf4,8'hfc,8'hfd,8'hfd,8'hf8,8'hf5,8'hfa,8'hfe,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hb5,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hde,8'hda,8'hff,8'hfe,8'hda,8'hf9,8'hf9,8'hfd,8'hfd,8'hfd,8'hff,8'hff,8'hff,8'hfd,8'hf4,8'hf4,8'hf5,8'hff,8'hfe,8'hda,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hfe,8'hf9,8'hf5,8'hf9,8'hfd,8'hff,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hfd,8'hf0,8'hfd,8'hfe,8'hff,8'hff,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hfe,8'hfe,8'hfd,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hf4,8'hf9,8'hf9,8'hfe,8'hff,8'hda,8'hff,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hfe,8'hfa,8'hfd,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfd,8'hf9,8'hfa,8'hfa,8'hfe,8'hfe,8'hff,8'hfa,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hda,8'hf9,8'hf9,8'hf9,8'hfd,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hf9,8'hfa,8'hfe,8'hff,8'hff,8'hff,8'hfe,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hfe,8'hfd,8'hf9,8'hf9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hf9,8'hd5,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hb6,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hfe,8'hda,8'hf9,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfd,8'hfd,8'hfa,8'hda,8'hfe,8'hff,8'hff,8'hb6,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h95,8'hb6,8'hda,8'hff,8'hfe,8'hff,8'hfe,8'hfe,8'hf9,8'hfd,8'hfd,8'hfe,8'hff,8'hfe,8'hfe,8'hfe,8'hf9,8'hf9,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h91,8'h91,8'hda,8'hfe,8'hff,8'hff,8'hfe,8'hb5,8'hfa,8'hf9,8'hff,8'hfd,8'hff,8'hfd,8'hfd,8'hfe,8'hf5,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h91,8'h91,8'hb6,8'hb6,8'hfe,8'hff,8'hff,8'hfe,8'hf9,8'hf8,8'hf9,8'hf9,8'hfd,8'hf5,8'hfa,8'hf5,8'hf9,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hb5,8'h95,8'hda,8'hb6,8'hff,8'hfe,8'hff,8'hfa,8'hf5,8'hf5,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hb6,8'hda,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h91,8'hb6,8'hb6,8'hfd,8'hb6,8'hff,8'hf9,8'hda,8'hda,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hfa,8'hb6,8'hda,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hd6,8'hb6,8'hb6,8'hb6,8'hb6,8'hda,8'hfe,8'hfa,8'hfe,8'hda,8'hda,8'hda,8'hfe,8'hff,8'hb6,8'hda,8'hda,8'hd6,8'hb5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h71,8'h91,8'hb5,8'hb5,8'hda,8'hff,8'hfe,8'hda,8'hb6,8'hb6,8'hda,8'hb6,8'hff,8'hb6,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hb5,8'hd6,8'hb6,8'hb5,8'hb6,8'hda,8'hff,8'hff,8'hff,8'hff,8'hb5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hb5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
    };

    logic [0:31] [0:31] [7:0] explosion_smoke = { 
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hde,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hba,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hda,8'hda,8'hff,8'hde,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hdf,8'hff,8'hff,8'hff,8'hff,8'hff,8'hde,8'hff,8'hff,8'hba,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hda,8'hff,8'hff,8'h91,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hda,8'hb5,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hda,8'hda,8'hff,8'hb6,8'hfe,8'hff,8'hff,8'hff,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hde,8'hb6,8'hff,8'hda,8'hb6,8'hff,8'hba,8'hda,8'hff,8'hff,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb5,8'hff,8'hff,8'hff,8'hba,8'hb6,8'h91,8'hff,8'hda,8'hda,8'hff,8'hff},
	{8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hba,8'hff,8'hb6,8'hda,8'hb6,8'hda,8'hda,8'hff},
	{8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hff,8'hff,8'hff,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hfe,8'hb6,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hb6,8'hb6},
	{8'hff,8'hff,8'hff,8'h6d,8'hda,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h91,8'hff,8'hff,8'h95,8'hff},
	{8'hff,8'hff,8'hff,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hb6,8'hff},
	{8'hff,8'hff,8'hb6,8'hda,8'h91,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hdf,8'hda,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hba,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h91,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h91,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hda,8'h91,8'hda,8'hda,8'hda,8'hba,8'hda,8'hda,8'hb6,8'hfe,8'hb6,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hda,8'hda,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h91,8'h91,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hb5,8'h91,8'hb6,8'hda,8'hda,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hda,8'hb6,8'hb6,8'hff,8'hff,8'hb6,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb5,8'hb6,8'hb6,8'hb6,8'hdf,8'hff,8'hda,8'hba,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hda,8'hb6,8'h91,8'hda,8'hb6,8'hb5,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hda,8'h91,8'h95,8'hb5,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hb6,8'hb6,8'hba,8'hff,8'hda,8'hb6,8'hda,8'hda,8'hb6,8'hb6,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h91,8'hff,8'hff,8'hff,8'hff,8'h91,8'hff,8'hb1,8'hb5,8'h6c,8'hfe,8'hfe,8'hb6,8'hda,8'hb6,8'hb6,8'hb5,8'hb6,8'hb6,8'hb6,8'hb5,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hb6,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb5,8'hb6,8'hd6,8'hb6,8'hb5,8'hb5,8'h6c,8'hff,8'h96,8'hff,8'hff,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb5,8'hb6,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff} 
    };
	 
	 logic [0:31] [0:31] [7:0] arrow_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
	};
	 
    // --- Hit Map (Circular) ---
    logic [0:15] [0:15] [2:0] hit_colors = {
        48'o4443333333333444, 48'o4443333333333444, 48'o1443333333333442, 48'o1144333333334422,
        48'o1114433333344222, 48'o1111444444422222, 48'o1111144444222222, 48'o1111114442222222,
        48'o1111114442222222, 48'o1111144444222222, 48'o1111440004422222, 48'o1114400000044222,
        48'o1144000000004422, 48'o1440000000000442, 48'o4440000000000444, 48'o4440000000000444 
    };

    
    logic signed [9:0] cos_val, sin_val;
    logic [8:0] rounded_angle;

    // Rounding Helper
    assign rounded_angle = ((Angle + 9'd2) / 9'd5) * 9'd5;

    always_comb begin
        case (rounded_angle)
            
            // --- 0 DEGREES: DOWN (Identity) ---
            0:   begin cos_val =  256; sin_val =    0; end
            
            // --- RIGHT SWING (0 to 90) ---
            5:   begin cos_val =  255; sin_val =   22; end
            10:  begin cos_val =  252; sin_val =   44; end
            15:  begin cos_val =  247; sin_val =   66; end
            20:  begin cos_val =  241; sin_val =   88; end
            25:  begin cos_val =  232; sin_val =  108; end
            30:  begin cos_val =  222; sin_val =  128; end
            35:  begin cos_val =  210; sin_val =  147; end
            40:  begin cos_val =  196; sin_val =  165; end
            45:  begin cos_val =  181; sin_val =  181; end
            50:  begin cos_val =  165; sin_val =  196; end
            55:  begin cos_val =  147; sin_val =  210; end
            60:  begin cos_val =  128; sin_val =  222; end
            65:  begin cos_val =  108; sin_val =  232; end
            70:  begin cos_val =   88; sin_val =  241; end
            75:  begin cos_val =   66; sin_val =  247; end
            80:  begin cos_val =   44; sin_val =  252; end
            85:  begin cos_val =   22; sin_val =  255; end
            90:  begin cos_val =    0; sin_val =  256; end // Pure Right

            // --- LEFT SWING (270 to 360/0) ---
            // Note: Physics outputs -5 as 355
            270: begin cos_val =    0; sin_val = -256; end // Pure Left
            275: begin cos_val =   22; sin_val = -255; end
            280: begin cos_val =   44; sin_val = -252; end
            285: begin cos_val =   66; sin_val = -247; end
            290: begin cos_val =   88; sin_val = -241; end
            295: begin cos_val =  108; sin_val = -232; end
            300: begin cos_val =  128; sin_val = -222; end
            305: begin cos_val =  147; sin_val = -210; end
            310: begin cos_val =  165; sin_val = -196; end
            315: begin cos_val =  181; sin_val = -181; end
            320: begin cos_val =  196; sin_val = -165; end
            325: begin cos_val =  210; sin_val = -147; end
            330: begin cos_val =  222; sin_val = -128; end
            335: begin cos_val =  232; sin_val = -108; end
            340: begin cos_val =  241; sin_val =  -88; end
            345: begin cos_val =  247; sin_val =  -66; end
            350: begin cos_val =  252; sin_val =  -44; end
            355: begin cos_val =  255; sin_val =  -22; end
            360: begin cos_val =  256; sin_val =    0; end // Wrap to 0

            default: begin 
                // Default to Down (0)
                cos_val = 256; sin_val = 0; 
            end
        endcase
    end
	 
	 
	 logic signed [10:0] centered_X, centered_Y;
    logic signed [19:0] rot_X_calc, rot_Y_calc; // 20 bits for multiplication result
    logic signed [10:0] read_X, read_Y;         // Final coordinates to read from memory

    always_comb begin
        // A. Shift Origin to Center (16, 16)
        centered_X = $signed(offsetX) - CENTER_X;
        centered_Y = $signed(offsetY) - CENTER_Y;

        // B. Apply Rotation Matrix
        // To rotate the IMAGE by Angle, we rotate the COORDINATES by -Angle.
        // Formula for -Angle:
        // x' =  x * cos(a) + y * sin(a)
        // y' = -x * sin(a) + y * cos(a)
        
        rot_X_calc = (centered_X * cos_val) + (centered_Y * sin_val);
        rot_Y_calc = (centered_Y * cos_val) - (centered_X * sin_val);

        // C. Scale back (Divide by 256) and Un-center
        // We add CENTER back to return to (0..31) space
        read_X = (rot_X_calc >>> 8) + CENTER_X;
        read_Y = (rot_Y_calc >>> 8) + CENTER_Y;
    end
	 
		
	// --- Selection Logic ---
    logic [7:0] selected_RGB;
    logic [4:0] mirroredX;
    assign mirroredX = 5'd31 - offsetX[4:0];
	
	 always_comb begin
		  selected_RGB = TRANSPARENT;
		  
		  if (InsideRectangle) begin
				if (ExplosionState == 2'b01) begin
					 selected_RGB = explosion_fire[offsetY][offsetX];
				end
				else if (ExplosionState == 2'b10) begin
					 selected_RGB = explosion_smoke[offsetY][offsetX];
				end
				else begin
					 // ROTATION RENDERING
					 // 1. Check Bounds: If rotation pushes pixel outside 32x32 area, make transparent
					 if (read_X >= 0 && read_X < OBJECT_WIDTH_X && read_Y >= 0 && read_Y < OBJECT_HEIGHT_Y) begin
						  if(aimingFlag)
								selected_RGB = arrow_colors[read_Y][read_X];
						  else
								selected_RGB = bomb_sprite[read_Y][read_X];		
					 end
					 // Else stays TRANSPARENT
				end
		  end
	 end
	 
	 
    // --- Output Pipeline ---
	 
    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            RGBout <= 8'h00;
            HitEdgeCode <= 3'h0;
        end
        else begin
            RGBout <= selected_RGB;
            HitEdgeCode <= 3'h0;
            if (InsideRectangle) HitEdgeCode <= hit_colors[HitCodeY][HitCodeX];
        end
    end
    assign drawingRequest = (RGBout != TRANSPARENT);
endmodule