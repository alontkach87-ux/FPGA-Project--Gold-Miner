
// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     
		  // add the box for numbers here 
			
			  
			  
		  ////////////////////////
		  // background 
					input    logic bombDrawingRequest, 
					input		logic	[7:0] bombRGB,   
					input		logic	BGDrawingRequest,
					input		logic	[7:0] backGroundRGB, 	
					input		logic	[7:0] RGB_MIF, 
					input    logic characterDrawingRequest,
					input    logic [7:0] characterRGB,
					input 	logic lootDrawingRequest,
					input		logic [7:0] lootRGB,
					input 	logic gameDataDrawingRequest,
					input		logic [7:0] gameDataRGB,
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (bombDrawingRequest == 1'b1 )   
			RGBOut <= bombRGB;   
		else if(characterDrawingRequest == 1'b1)
			RGBOut <= characterRGB;  
 		else if (lootDrawingRequest == 1'b1)
				RGBOut <= lootRGB;
		else if(gameDataDrawingRequest == 1'b1)
				RGBOut <= gameDataRGB;
		else if (BGDrawingRequest == 1'b1)
				RGBOut <= backGroundRGB ;
		else RGBOut <= RGB_MIF ;
		end ; 
	end

endmodule


