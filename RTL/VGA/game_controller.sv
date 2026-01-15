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
			input logic [9:0] score, //score input from maze
			input logic [9:0] keys,  //keyboard keys for user interaction

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse,
		   output logic collision_explosion_maze,// critical code, generating A single pulse in a frame 
			output logic [9:0] timePassed, //timer
			output logic [1:0] currentLevel, //currect game level (1 to 3)
			output logic gameOver, //signal that game is over (user lost)
			output logic shop, //signal that user is currently in the shop between levels
			output logic victory, //signal that user won
			output logic newLevel, //signal that there's a new level
			output logic start,   //signal that game is started
			output logic genderSwap, //signal for miner gender swap
			output logic [9:0] money, //amount of money for the shop
			output logic aimReset,   //signal to reset the aiming of the bomb
			output logic startAudio, //signal for the game start audio
			output logic gameOverAudio, //signal of the game over audio
			output logic victoryAudio, //signal for the victory audio
			output logic luckyCharm,	//signal for the lucky charm upgrade (20% more score in the level it's active)  - display signal
			output logic gemDetector,  //signal for the gemDetector upgrade (all treasures turn to gems) - display signal
			output logic delay,			//signal for the delay upgrade (5 second delay)  - display signal
			output logic gemDetectorSignal //signal for the gemDetector upgrade (all treasures turn to gems) - enable signal
			

);

//constants - required scores for passing each level, and required money for upgrades

localparam int REQUIRED_SCORE_LEVEL_ONE = 100;
localparam int REQUIRED_SCORE_LEVEL_TWO = 150;
localparam int REQUIRED_SCORE_LEVEL_THREE = 180;
localparam int REQUIRED_MONEY_LUCKY_CHARM = 150;
localparam int REQUIRED_MONEY_GEM_DETECTOR = 100;
localparam int REQUIRED_MONEY_DELAY = 50;

//internal wires

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
logic [3:0] timerGemDetector;
logic gemDetectorSignalFlag;

//game state machine states

enum logic [2:0] {
		  START_ST,
        LEVEL_ONE_ST, 
        LEVEL_TWO_ST, 
        LEVEL_THREE_ST, 
        GAME_OVER_ST, 
        SHOP_ST,
		  VICTORY_ST
    } SM_Game;
//assignments and always comb for outputs
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
assign gemDetectorSignal=gemDetectorSignalFlag;

//state machine logic

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)//reset
	begin 
		SM_Game <= START_ST;
		newLevelFlag <= 0;
	end 
	else begin 
      newLevelFlag <= 0;
      SingleHitPulse <= 0;
		case (SM_Game)//start screen, all outputs in initial state
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
					if(keys[1] == 1'b1) begin //game start
						SM_Game <= LEVEL_ONE_ST;
						aimResetFlag <= 1;
						newLevelFlag <= 1;
						startAudioFlag <= 1;
					end
					if(keys[5] == 1'b1) //gender swap
						genderSwapFlag <= 1;
				end
				LEVEL_ONE_ST: begin //level one
					startFlag <= 0;
					genderSwapFlag <= 0;
					if(keys[9] == 1'b1) //game restart
						SM_Game <= START_ST;
					if(startOfFrame) begin 
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1; //increment frame counter
						if(timer == 50 && frame_counter == 63)
							startAudioFlag <= 0;
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin		//check level conditions after time ends
								if(score >= REQUIRED_SCORE_LEVEL_ONE) begin	//if user passed the level
									timer <= 20;
									currentMoney <= score - REQUIRED_SCORE_LEVEL_ONE;
									SM_Game <= SHOP_ST;
									shopFlag <= 1;
									level <= 2;
								end
								else begin	//if user failed the level
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
						end
					end
				end 
				LEVEL_TWO_ST: begin  //level two
					if(keys[9] == 1'b1) //game restart
						SM_Game <= START_ST; 
					//upgrade conditions - only from level 2 the user has access to upgrades
					if(keys[5] == 1'b1 && delayFlag == 1) begin //user actives delay upgrade
						timer <= timer + 5;
						delayFlag <= 0;
					end
					if(keys[6] == 1'b1 && gemDetectorFlag == 1) begin //user actives gem detector upgrade - the upgrade timer starts counting
						timerGemDetectorEnable <= 1;
						gemDetectorSignalFlag <= 1;
						gemDetectorFlag <= 0;
					end
					if(startOfFrame) begin
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1; //increment frame counter
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin	//check level conditions after time ends
								if(score >= REQUIRED_SCORE_LEVEL_TWO) begin //if user passed the level
									if(gemDetectorSignalFlag == 1) begin //deactivate gem detector upgrade in the end of the level
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)	//deactivate lucky charm upgrade in the end of the level
										luckyCharmFlag <= 0;
									timer <= 20;
									currentMoney <= score - REQUIRED_SCORE_LEVEL_TWO;
									SM_Game <= SHOP_ST;
									shopFlag <= 1;
									level <= 3;
								end
								else begin //if user failed the level
									if(gemDetectorSignalFlag == 1) begin //deactivate gem detector upgrade in the end of the level
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1) //deactivate lucky charm upgrade in the end of the level
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
							if(timerGemDetectorEnable == 1'b1) begin  //increment gem detector timer
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
				LEVEL_THREE_ST: begin //level three - final level
					if(keys[9] == 1'b1) //game restart
						SM_Game <= START_ST;
					if(keys[5] == 1'b1 && delayFlag == 1) begin //user actives delay upgrade
						timer <= timer + 5;
						delayFlag <= 0;
					end
					if(keys[6] == 1'b1 && gemDetectorFlag == 1) begin //user actives gem detector upgrade - the upgrade timer starts counting
						timerGemDetectorEnable <= 1;
						gemDetectorSignalFlag <= 1;
						gemDetectorFlag <= 0;
					end
					if(startOfFrame) begin
						aimResetFlag <= 0;
						flag <= 1'b0 ; // reset for next time 
						frame_counter <= frame_counter + 1; //increment frame counter
						if(frame_counter >= 72) begin //if 72 frames passed, one second passed
							frame_counter <= 0;
							timer <= timer - 1;
							if(timer == 0) begin		//check level conditions after time ends
								if(score >= REQUIRED_SCORE_LEVEL_THREE) begin //if user passed the level
									if(gemDetectorSignalFlag == 1) begin //deactivate gem detector upgrade in the end of the level
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1)	//deactivate lucky charm upgrade in the end of the level
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= VICTORY_ST;
									victoryFlag <= 1;
									victoryAudioFlag <= 1;
								end
								else begin //if user failed the level
									if(gemDetectorSignalFlag == 1) begin //deactivate gem detector upgrade in the end of the level
										timerGemDetectorEnable <= 0;
										timerGemDetector <= 0;
										gemDetectorSignalFlag <= 0;
									end
									if(luckyCharmFlag == 1'b1) //deactivate lucky charm upgrade in the end of the level
										luckyCharmFlag <= 0;
									timer <= 0;
									SM_Game <= GAME_OVER_ST;
									gameOverFlag <= 1;
									gameOverAudioFlag <= 1;
								end
							end
							if(timerGemDetectorEnable == 1'b1) begin //increment gem detector timer
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
				SHOP_ST: begin //shop state - between levels
					if(keys[9] == 1'b1) //game restart
						SM_Game <= START_ST;
					if(keys[5] == 1'b1 && currentMoney >= REQUIRED_MONEY_DELAY && delayFlag == 0) begin //user buys delay upgrade
						delayFlag <= 1;
						currentMoney <= currentMoney - REQUIRED_MONEY_DELAY;
					end
					if(keys[6] == 1'b1 && currentMoney >= REQUIRED_MONEY_GEM_DETECTOR && gemDetectorFlag == 0) begin //user buys gem detector upgrade
						gemDetectorFlag <= 1;
						currentMoney <= currentMoney - REQUIRED_MONEY_GEM_DETECTOR;
					end
					if(keys[7] == 1'b1 && currentMoney >= REQUIRED_MONEY_LUCKY_CHARM && luckyCharmFlag == 0) begin //user buys lucky charm upgrade
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
								if(level == 2) begin //if level is 2, go to level two
									timer <= 45;
									SM_Game <= LEVEL_TWO_ST;
									shopFlag <= 0;
									aimResetFlag <= 1;
									newLevelFlag <= 1;
								end
								else if(level == 3) begin //if level is 3, go to level three
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
				VICTORY_ST: begin //victory state - constant state
					if(startOfFrame) begin
						frame_counter <= frame_counter + 1;
						if(frame_counter == 130) //flag for victory audio goes down after circa 1.8 seconds
							victoryAudioFlag <= 0;
					end
					if(keys[9] == 1'b1) // game restart
						SM_Game <= START_ST;
					victoryFlag <= 1;
				end 
				GAME_OVER_ST: begin //game over state - constant state
					if(startOfFrame) begin
						frame_counter <= frame_counter + 1;
						if(frame_counter == 156) //flag for audio goes down after circa 2.2 seconds
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
