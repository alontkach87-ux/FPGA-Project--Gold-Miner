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
			output logic [9:0] money,
			output logic aimReset,
			output logic startAudio,
			output logic gameOverAudio,
			output logic victoryAudio,
			output logic luckyCharm,
			output logic gemDetector,
			output logic delay,
			output logic gemDetectorSignal
			

);

localparam int REQUIRED_SCORE_LEVEL_ONE = 100;
localparam int REQUIRED_SCORE_LEVEL_TWO = 150;
localparam int REQUIRED_SCORE_LEVEL_THREE = 180;
localparam int REQUIRED_MONEY_LUCKY_CHARM = 150;
localparam int REQUIRED_MONEY_GEM_DETECTOR = 100;
localparam int REQUIRED_MONEY_DELAY = 50;



logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic [7:0] frame_counter;
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
logic aimResetFlag;
logic startAudioFlag;
logic gameOverAudioFlag;
logic victoryAudioFlag;
logic luckyCharmFlag;
logic gemDetectorFlag;
logic delayFlag;
logic timerGemDetectorEnable;
logic timerGemDetector;
logic gemDetectorSignalFlag;

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
	collision_explosion_maze = 1'b0;
	if(drawing_request_bomb && drawing_request_maze && (ExplosionState != 2'b00)) begin
	   collision_explosion_maze = 1'b1;
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
assign aimReset = aimResetFlag;
assign startAudio = startAudioFlag;
assign gameOverAudio = gameOverAudioFlag;
assign victoryAudio = victoryAudioFlag;
assign luckyCharm = luckyCharmFlag;
assign gemDetector = gemDetectorFlag;
assign delay = delayFlag;
assign gemDetectorSignalFlag = gemDetectorSignal;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		SM_Game <= START_ST;
		newLevelFlag <= 0;
	end 
	else begin 
      newLevelFlag <= 0;
      SingleHitPulse <= 0;
		case (SM_Game)
				START_ST: begin
					flag	<= 1'b0;
					SingleHitPulse <= 1'b0 ; 
					frame_counter <= 0;
					level <= 1;
					timer <= 50;
					gameOverFlag <= 0;
					victoryFlag <= 0;
					gameOverAudioFlag <= 0;
					victoryAudioFlag <= 0;
					startAudioFlag <= 0;
					shopFlag <= 0;
					luckyCharmFlag <= 0;
					gemDetectorFlag <= 0;
					timerGemDetectorEnable <= 0;
					timerGemDetector <= 0;
					gemDetectorSignalFlag <= 0;
					delayFlag <= 0;
					currentMoney <= 0;
					startFlag <= 1;
					aimResetFlag <= 0;
					if(keys[1] == 1'b1) begin
						SM_Game <= LEVEL_ONE_ST;
						aimResetFlag <= 1;
						newLevelFlag <= 1;
						startAudioFlag <= 1;
					end
					if(keys[5] == 1'b1)
						genderSwapFlag <= 1;
				end
				LEVEL_ONE_ST: begin
					startFlag <= 0;
					genderSwapFlag <= 0;
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(startOfFrame) begin
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(timer == 50 && frame_counter == 63)
							startAudioFlag <= 0;
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
								end
								else begin
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
						end
					end
				end
				LEVEL_TWO_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(keys[5] == 1'b1 && delayFlag == 1) begin
						timer <= timer + 5;
						delayFlag <= 0;
					end
					if(keys[6] == 1'b1 && gemDetectorFlag == 1) begin
						timerGemDetectorEnable <= 1;
						gemDetectorSignalFlag <= 1;
						gemDetectorFlag <= 0;
					end
					if(startOfFrame) begin
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin			
								if(score >= REQUIRED_SCORE_LEVEL_TWO) begin
									if(gemDetectorSignalFlag == 1) begin
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)
										luckyCharmFlag <= 0;
									timer <= 20;
									currentMoney <= score - REQUIRED_SCORE_LEVEL_TWO;
									SM_Game <= SHOP_ST;
									shopFlag <= 1;
									level <= 3;
								end
								else begin
									if(gemDetectorSignalFlag == 1) begin
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
							if(timerGemDetectorEnable == 1'b1) begin
								timerGemDetector <= timerGemDetector + 1;
								if(timerGemDetector == 10) begin
									timerGemDetectorEnable <= 0;
									timerGemDetector <= 0;
									gemDetectorSignalFlag <= 0;
								end
							end
						end
					end
				end
				LEVEL_THREE_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(keys[5] == 1'b1 && delayFlag == 1) begin
						timer <= timer + 5;
						delayFlag <= 0;
					end
					if(keys[6] == 1'b1 && gemDetectorFlag == 1) begin
						timerGemDetectorEnable <= 1;
						gemDetectorSignalFlag <= 1;
						gemDetectorFlag <= 0;
					end
					if(startOfFrame) begin
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin			
								if(score >= REQUIRED_SCORE_LEVEL_THREE) begin
									if(gemDetectorSignalFlag == 1) begin
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= VICTORY_ST;
									victoryFlag <= 1;
									victoryAudioFlag <= 1;
								end
								else begin
									if(gemDetectorSignalFlag == 1) begin
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
							if(timerGemDetectorEnable == 1'b1) begin
								timerGemDetector <= timerGemDetector + 1;
								if(timerGemDetector == 10) begin
									timerGemDetectorEnable <= 0;
									timerGemDetector <= 0;
									gemDetectorSignalFlag <= 0;
								end
							end
						end
					end
				end
				SHOP_ST: begin
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					if(keys[5] == 1'b1 && currentMoney >= REQUIRED_MONEY_DELAY && delayFlag == 0) begin
						delayFlag <= 1;
						currentMoney <= currentMoney - REQUIRED_MONEY_DELAY;
					end
					if(keys[6] == 1'b1 && currentMoney >= REQUIRED_MONEY_GEM_DETECTOR && gemDetectorFlag == 0) begin
						gemDetectorFlag <= 1;
						currentMoney <= currentMoney - REQUIRED_MONEY_GEM_DETECTOR;
					end
					if(keys[7] == 1'b1 && currentMoney >= REQUIRED_MONEY_LUCKY_CHARM && luckyCharmFlag == 0) begin
						luckyCharmFlag <= 1;
						currentMoney <= currentMoney - REQUIRED_MONEY_LUCKY_CHARM;
					end
					if(startOfFrame) begin
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin
								if(level == 2) begin
									timer <= 45;
									SM_Game <= LEVEL_TWO_ST;
									shopFlag <= 0;
									aimResetFlag <= 1;
									newLevelFlag <= 1;
								end
								else if(level == 3) begin
									timer <= 40;
									SM_Game <= LEVEL_THREE_ST;
									shopFlag <= 0;
									aimResetFlag <= 1;
									newLevelFlag <= 1;
								end
							end
						end
					end
				end
				VICTORY_ST: begin
					if(startOfFrame) begin
						frame_counter <= frame_counter + 1;
						if(frame_counter == 130)
							victoryAudioFlag <= 0;
					end
					if(keys[9] == 1'b1)
						SM_Game <= START_ST;
					victoryFlag <= 1;
				end
				GAME_OVER_ST: begin
					if(startOfFrame) begin
						frame_counter <= frame_counter + 1;
						if(frame_counter == 156)
							gameOverAudioFlag <= 0;
					end
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
