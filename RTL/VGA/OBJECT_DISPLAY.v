// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Intel and sold by Intel or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"
// CREATED		"Sun Jan 11 18:29:12 2026"

module OBJECT_DISPLAY(
	resetN,
	HART_SELECT,
	clk,
	collision_bomb_object,
	newLevel,
	ExplosionState,
	keyIsPressed,
	Level_number,
	pixelX,
	pixelY,
	topLeftX,
	topLeftY,
	MazeDrawingRequest,
	Is_Rock,
	MazeRGB,
	Score
);


input wire	resetN;
input wire	HART_SELECT;
input wire	clk;
input wire	collision_bomb_object;
input wire	newLevel;
input wire	[1:0] ExplosionState;
input wire	[1:1] keyIsPressed;
input wire	[1:0] Level_number;
input wire	[10:0] pixelX;
input wire	[10:0] pixelY;
input wire	[10:0] topLeftX;
input wire	[10:0] topLeftY;
output wire	MazeDrawingRequest;
output wire	Is_Rock;
output wire	[7:0] MazeRGB;
output wire	[9:0] Score;

wire	boxHartDrawingRequest;
wire	[10:0] BoxHartTopLeftX;
wire	[10:0] BoxHartTopLeftY;
wire	[2:0] map_random;





square_object1	b2v_inst(
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.topLeftX(topLeftX),
	.topLeftY(topLeftY),
	.drawingRequest(boxHartDrawingRequest),
	.offsetX(BoxHartTopLeftX),
	.offsetY(BoxHartTopLeftY)
	);
	defparam	b2v_inst.OBJECT_COLOR = 8'b00000011;
	defparam	b2v_inst.OBJECT_HEIGHT_Y = 320;
	defparam	b2v_inst.OBJECT_WIDTH_X = 512;


random	b2v_inst1(
	.clk(clk),
	.resetN(resetN),
	.rise(keyIsPressed),
	.dout(map_random));
	defparam	b2v_inst1.MAX_VAL = 5;
	defparam	b2v_inst1.MIN_VAL = 0;
	defparam	b2v_inst1.SIZE_BITS = 3;


MazeMatrixBitMap	b2v_inst2(
	.clk(clk),
	.resetN(resetN),
	.InsideRectangle(boxHartDrawingRequest),
	.random_hart(HART_SELECT),
	.collision_bomb_object(collision_bomb_object),
	.newLevel(newLevel),
	.ExplosionState(ExplosionState),
	.level_input(Level_number),
	.map_randomizer(map_random),
	.offsetX(BoxHartTopLeftX),
	.offsetY(BoxHartTopLeftY),
	.drawingRequest(MazeDrawingRequest),
	.Is_Rock(Is_Rock),
	.counter_Score(Score),
	.RGBout(MazeRGB));


endmodule
