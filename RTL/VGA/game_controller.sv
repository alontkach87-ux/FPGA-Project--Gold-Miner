// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_character,
			input	logic	drawing_request_bomb,
			input	logic	drawing_request_maze,
			input logic [1:0] ExplosionState,
			input logic [9:0] score,
			input logic [9:0] keys,

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse,
		   output logic collision_explosion_maze,// critical code, generating A single pulse in a frame 
			output logic [9:0] timePassed,
			output logic [1:0] currentLevel,
			output logic gameOver,
			output logic shop,
			output logic victory,
			output logic newLevel,
			output logic start,
			output logic genderSwap,
			output logic [9:0] money
			

);

localparam int REQUIRED_SCORE_LEVEL_ONE = 300;
localparam int REQUIRED_SCORE_LEVEL_TWO = 350;
localparam int REQUIRED_SCORE_LEVEL_THREE = 400;



logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic [6:0] frame_counter;
//logic	score,
logic [9:0] timer;
logic [1:0] level;
logic required_score;
logic gameOverFlag;
logic shopFlag;
logic victoryFlag;
logic newLevelFlag;
logic startFlag;
logic genderSwapFlag;
logic [9:0] currentMoney;

enum logic [2:0] {
		  START_ST,
        LEVEL_ONE_ST, 
        LEVEL_TWO_ST, 
        LEVEL_THREE_ST, 
        GAME_OVER_ST, 
        SHOP_ST,
		  VICTORY_ST
    } SM_Game;


always_comb begin
	if(drawing_request_bomb && drawing_request_maze && (ExplosionState != 2'b00)) begin
		collision_explosion_maze = 1'b1;
	end	
	else begin
		collision_explosion_maze = 1'b0;
	end
end





assign timePassed = timer;
assign currentLevel = level;
assign victory = victoryFlag;
assign gameOver = gameOverFlag;
assign shop = shopFlag;
assign newLevel = newLevelFlag;
assign start = startFlag;
assign genderSwap = genderSwapFlag;
assign money = currentMoney;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		SM_Game <= START_ST;
	end 
	else begin 
		case (SM_Game)
				START_ST: begin
					flag	<= 1'b0;
					SingleHitPulse <= 1'b0 ; 
					frame_counter <= 0;
					level <= 1;
					timer <= 50;
					gameOverFlag <= 0;
					victoryFlag <= 0;
					shopFlag <= 0;
					newLevelFlag <= 0;
					currentMoney <= 0;
					startFlag <= 1;
					if(keys[1] == 1'b1)
						SM_Game <= LEVEL_ONE_ST;
					if(keys[5] == 1'b1)
						genderSwapFlag <= 1;
				end
				LEVEL_ONE_ST: begin
					startFlag <= 0;
					genderSwapFlag <= 0;
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(startOfFrame) begin
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin			
								if(score >= REQUIRED_SCORE_LEVEL_ONE) begin
									timer <= 20;
									currentMoney <= score - REQUIRED_SCORE_LEVEL_ONE;
									SM_Game <= SHOP_ST;
									shopFlag <= 1;
									level <= 2;
									newLevelFlag <= 1;
								end
								else begin
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
								end
							end
						end
					end
				end
				LEVEL_TWO_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(startOfFrame) begin
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin			
								if(score >= REQUIRED_SCORE_LEVEL_TWO) begin
									timer <= 20;
									currentMoney <= score - REQUIRED_SCORE_LEVEL_TWO;
									SM_Game <= SHOP_ST;
									shopFlag <= 1;
									level <= 3;
									newLevelFlag <= 1;
								end
								else begin
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
								end
							end
						end
					end
				end
				LEVEL_THREE_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(startOfFrame) begin
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin			
								if(score >= REQUIRED_SCORE_LEVEL_THREE) begin
									timer <= 0;
									SM_Game <= VICTORY_ST;
									victoryFlag <= 1;
								end
								else begin
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
								end
							end
						end
					end
				end
				SHOP_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(startOfFrame) begin
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							newLevelFlag <= 0;
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin
								if(level == 2) begin
									timer <= 45;
									SM_Game <= LEVEL_TWO_ST;
									shopFlag <= 0;
								end
								else if(level == 3) begin
									timer <= 40;
									SM_Game <= LEVEL_THREE_ST;
									shopFlag <= 0;
								end
							end
						end
					end
				end
				VICTORY_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					victoryFlag <= 1;
				end
				GAME_OVER_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					gameOverFlag <= 1;
				end
			endcase
			if ( collision_explosion_maze  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end
		end
		  
 
end

endmodule
