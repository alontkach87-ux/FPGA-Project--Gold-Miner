
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
					input    logic scoreWordDrawingRequest,
					input    logic [7:0] scoreWordRGB,
					input    logic timeWordDrawingRequest,
					input    logic [7:0] timeWordRGB,
					input    logic levelWordDrawingRequest,
					input    logic [7:0] levelWordRGB,
					input    logic slashDrawingRequest,
					input    logic [7:0] slashRGB,
					input    logic currLevelDrawingRequest,
					input    logic [7:0] currLevelRGB,
					input    logic reqScoreDrawingRequest,
					input    logic [7:0] reqScoreRGB,
					input    logic startDrawingRequest,
					input    logic [7:0] moneyWordRGB,
					input    logic moneyWordDrawingRequest,
					input    logic [7:0] moneyRGB,
					input    logic moneyDrawingRequest,
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	else if(startDrawingRequest == 1'b1 || victoryDrawingRequest == 1'b1 || gameOverDrawingRequest == 1'b1)
		RGBOut <= RGB_MIF;
	else if(shopDrawingRequest == 1'b1) begin
		if(timeWordDrawingRequest == 1'b1)
			RGBOut <= timeWordRGB;
		else if(timerDrawingRequest == 1'b1)
			RGBOut <= timerRGB;
		else if(moneyWordDrawingRequest == 1'b1)
			RGBOut <= moneyWordRGB;
		else if(moneyDrawingRequest == 1'b1)
			RGBOut <= moneyRGB;
		else
			RGBOut <= RGB_MIF;
	end
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
		else if(scoreWordDrawingRequest == 1'b1)
			RGBOut <= scoreWordRGB;
		else if(timeWordDrawingRequest == 1'b1)
			RGBOut <= timeWordRGB;
		else if(levelWordDrawingRequest == 1'b1)
			RGBOut <= levelWordRGB;
		else if(slashDrawingRequest == 1'b1)
			RGBOut <= slashRGB;
		else if(currLevelDrawingRequest == 1'b1)
			RGBOut <= currLevelRGB;
		else if(reqScoreDrawingRequest == 1'b1)
			RGBOut <= reqScoreRGB;
		else 
			RGBOut <= RGB_MIF;
		end ;	
	end

endmodule


