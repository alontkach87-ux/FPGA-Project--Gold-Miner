
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
					     
		  // add the box for numbers here 
			
			  
			  
		  ////////////////////////
		  // background 
					input    logic bombDrawingRequest, 
					input		logic	[7:0] bombRGB,	
					input		logic	[7:0] RGB_MIF, 
					input    logic characterDrawingRequest,
					input    logic [7:0] characterRGB,
					input 	logic lootDrawingRequest,
					input		logic [7:0] lootRGB,
					input 	logic scoreDrawingRequest,
					input		logic [7:0] scoreRGB,
					input    logic timerDrawingRequest,
					input    logic [7:0] timerRGB,
					input    logic victoryDrawingRequest,
					input    logic gameOverDrawingRequest,
					input    logic shopDrawingRequest,
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	else if(victoryDrawingRequest == 1'b1 || gameOverDrawingRequest == 1'b1 || shopDrawingRequest == 1'b1)
		if(scoreDrawingRequest == 1'b1)
				RGBOut <= scoreRGB;
		else if(timerDrawingRequest == 1'b1)
				RGBOut <= timerRGB;
		else
			RGBOut <= RGB_MIF;
	else begin
		if (bombDrawingRequest == 1'b1 )   
			RGBOut <= bombRGB;   
		else if(characterDrawingRequest == 1'b1)
			RGBOut <= characterRGB;  
 		else if (lootDrawingRequest == 1'b1)
				RGBOut <= lootRGB;
		else if(scoreDrawingRequest == 1'b1)
				RGBOut <= scoreRGB;
		else if(timerDrawingRequest == 1'b1)
				RGBOut <= timerRGB;
		else 
			RGBOut <= RGB_MIF;
		end ; 
	end

endmodule


