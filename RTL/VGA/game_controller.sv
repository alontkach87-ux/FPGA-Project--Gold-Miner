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

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse,
		   output logic collision_explosion_maze,// critical code, generating A single pulse in a frame 
			output logic [9:0] timePassed
			

);

logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic [6:0] frame_counter;
//logic	score,
logic [9:0] timer;
logic required_score;


always_comb begin
	if(drawing_request_bomb && drawing_request_maze && (ExplosionState != 2'b00)) begin
		collision_explosion_maze = 1'b1;
	end	
	else begin
		collision_explosion_maze = 1'b0;
	end
end





assign timePassed = timer;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		frame_counter <= 0;
		timer <= 59;
		
	end 
	else begin 
	
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) begin
				flag <= 1'b0 ; // reset for next time 
				frame_counter <= frame_counter + 1;
				if(frame_counter >= 72) begin //if 72 frames passed, one second passed
					frame_counter <= 0;
					timer <= timer - 1;
					if(timer == 0)
						timer <= 59;
				end
			end
				
  if ( collision_explosion_maze  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		 end  
 
		end 
end

endmodule
