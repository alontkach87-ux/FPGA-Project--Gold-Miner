// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_character,
			input	logic	drawing_request_bomb,
			input	logic	drawing_request_explosion,
			input	logic	drawing_request_maze,
			input	logic	drawing_request_hart,
			

//---------------------#1-add input drawing request of number/box
		
		
		

//---------------------#1-end input drawing request of number/box


// drawing_request_smiley   -->  smiley
// drawing_request_boarders -->  brackets
// drawing_request_number   -->  number/box 

//---------------------#2-add  drawing request of hart


//---------------------#2-end drawing request of hart		

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse,
		   output logic collision_explosion_maze// critical code, generating A single pulse in a frame 
			
			

//---------------------#3-add collision  smiley and hart   -------------------------------------

		//output logic collision_Smiley_Hart // active in case of collision between Smiley and hart

//---------------------#3-end collision  smiley and hart	--------------------------------------
			
);

logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 

//logic	score,
//logic timer,
logic required_score;


always_comb begin
	if(drawing_request_explosion && drawing_request_maze) begin
		collision_explosion_maze = 1'b1;
	end	
	else begin
		collision_explosion_maze = 1'b0;
	end
end



// collision between Smiley and number - is not output

//assign collision_before = (drawing_request_smiley && drawing_request_boarders || drawing_request_smiley && drawing_request_number);// any collision --> comment after updating with #4 or #5 

//---------------------#4-update  collision  conditions - add collision between smiley and number   ----------------------------

//assign collision = <collision_before> +<collision of smiley and number>; // any collision
//assign collision_smiley_number = <collision of smiley and number>;

//---------------------#4-end update  collision  conditions - add collision between smiley and number	-------------------------
	
					

//---------------------#5-update  collision  conditions - add collision between smiley and hart  ---------------------------------

//assign collision = collision_before || ( drawing_request_smiley && drawing_request_hart ); 

//---------------------#5-end update  collision  conditions	- add collision between smiley and hart	-----------------------------
	

//-------------------------- #6-add colision between Smiley and hart-----------------

//assign collision_Smiley_Hart = ( drawing_request_smiley && drawing_request_hart ) ;

//---------------------------#6-end colision betweenand Smiley and hart-----------------



always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		
	end 
	else begin 
	
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
//	----#7 - change the collision condition below to collision_smiley_number ---------

  if ( collision_explosion_maze  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		 end  
 
		end 
end

endmodule
