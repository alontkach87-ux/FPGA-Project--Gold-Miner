module RequiredScoreMux(

	input logic [1:0] level,
	output logic [9:0] requiredScore

);
	
	localparam int REQUIRED_SCORE_LEVEL_ONE = 300;
	localparam int REQUIRED_SCORE_LEVEL_TWO = 350;
	localparam int REQUIRED_SCORE_LEVEL_THREE = 400;

	
	always_comb begin
		if(level == 2'b01)
			requiredScore = REQUIRED_SCORE_LEVEL_ONE;
		else if(level == 2'b10)
			requiredScore = REQUIRED_SCORE_LEVEL_TWO;
		else if(level == 2'b11)
			requiredScore = REQUIRED_SCORE_LEVEL_THREE;
		else
			requiredScore = REQUIRED_SCORE_LEVEL_THREE;
	end
	
endmodule