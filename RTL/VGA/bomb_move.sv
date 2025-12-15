// (c) Technion IIT, Department of Electrical Engineering 2025 
module bomb_move #(
    // =============================================================
    // PARAMETER LIST (Defined using #( ... ) syntax)
    // =============================================================
    parameter int OBJECT_WIDTH_X = 32,
    parameter int OBJECT_HEIGHT_Y = 32
) (	
    // =============================================================
    // PORT LIST (Inputs and Outputs)
    // =============================================================
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,      
    input  logic Y_direction_key,   
    //input  logic Rotate_Left_Key,   //for now we won't rely on user input for angular aiming
    //input  logic Rotate_Right_Key,  
    input  logic collision,         
    input  logic [2:0] HitEdgeCode, 
    input  logic [7:0] random_fuse_time, 
	 
    output logic signed [10:0] topLeftX, 
    output logic signed [10:0] topLeftY, 
    output logic [8:0] Angle,            // 0-360 (Converted from internal -90 to +90)
    output logic [1:0] ExplosionState,
	 output logic explosionFlag
);

    // =============================================================
    // LOCAL PARAMETERS (Calculated internally)
    // =============================================================
    localparam int INITIAL_X = 280;
    localparam int INITIAL_Y = 50; 
    localparam int FIXED_POINT_MULTIPLIER = 64; 
    localparam int SafetyMargin = 2;            

    // Angular Limits
    // Range: -90 (Left) to +90 (Right)
    localparam int ANGLE_MIN = -90 * FIXED_POINT_MULTIPLIER;
    localparam int ANGLE_MAX =  90 * FIXED_POINT_MULTIPLIER;
    localparam int ANGLE_START = 0; // Starts pointing DOWN
    
    // Physics Constants
    //localparam int ANGLE_ACCEL = 10;
    //localparam int MAX_ANGLE_SPEED = 200;
    //localparam int ANGLE_FRICTION = 10;
	 // 30 deg/sec at 30Hz frame rate = 1 deg/frame
    localparam int SWING_SPEED = 1 * FIXED_POINT_MULTIPLIER;
    localparam int MAX_Y_SPEED = 500;
    localparam int Y_ACCEL = -10;
    
    // Boundaries (Calculated at Compile Time using localparam)
    localparam int x_FRAME_LEFT   = SafetyMargin * FIXED_POINT_MULTIPLIER;
    localparam int x_FRAME_RIGHT  = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER; 
    localparam int y_FRAME_TOP    = SafetyMargin * FIXED_POINT_MULTIPLIER;
    localparam int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HEIGHT_Y) * FIXED_POINT_MULTIPLIER;

    localparam int EXPLOSION_DURATION = 15; 

    // =============================================================
    // STATE MACHINE
    // =============================================================
    enum logic [2:0] {
        IDLE_ST, 
        AIMING_ST, 
        MOVING_ST, 
        START_OF_FRAME_ST, 
        POSITION_CHANGE_ST, 
        POSITION_LIMITS_ST,
        EXPLOSION_FIRE_ST, 
        EXPLOSION_SMOKE_ST 
    } SM_Motion;

    // =============================================================
    // INTERNAL SIGNALS
    // =============================================================
    int Xspeed, Yspeed, Xposition, Yposition;  
    int AngleSpeed, AnglePosition; 
    logic [4:0] hit_reg;
    int FuseCounter;    
    int AnimCounter;   

    // =============================================================
    // LOGIC
    // =============================================================
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin 
            SM_Motion <= IDLE_ST;
            Xspeed <= 0;
				Yspeed <= 0; 
            Xposition <= 0;
				Yposition <= 0; 
            AngleSpeed <= SWING_SPEED;
				AnglePosition <= ANGLE_START; 
            hit_reg <= 0;
				ExplosionState <= 2'b00;
				explosionFlag <= 0;
        end 
        else begin
            case(SM_Motion)
                IDLE_ST: begin
                    Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER;
                    Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 
                    AnglePosition <= ANGLE_START; 
                    AngleSpeed <= SWING_SPEED;
						  Xspeed <= 0;
						  Yspeed <= 0;
                    ExplosionState <= 2'b00;
						  explosionFlag <= 0; 
                    if (startOfFrame)
								SM_Motion <= AIMING_ST;
                end

                AIMING_ST: begin 
                    // Rotation Logic 
                    AnglePosition <= AnglePosition + AngleSpeed;
                    
                    if (AnglePosition >= ANGLE_MAX) begin 
								AnglePosition <= ANGLE_MAX;
								AngleSpeed <= -SWING_SPEED; 
						  end
                    if (AnglePosition < ANGLE_MIN) begin 
								AnglePosition <= ANGLE_MIN; 
								AngleSpeed <= SWING_SPEED; 
						  end

                    if (Y_direction_key) begin
                        Yspeed <= 200; 
                        FuseCounter <= {24'b0, random_fuse_time} + 30; 
                        SM_Motion <= MOVING_ST;
                    end
                    if (startOfFrame) 
						  SM_Motion <= AIMING_ST;
                end

                MOVING_ST: begin 
                    if (collision) 
								hit_reg[HitEdgeCode] <= 1'b1;
                    if (startOfFrame) begin
                        if (FuseCounter > 0) 
									FuseCounter <= FuseCounter - 1;
                        else begin
                            SM_Motion <= EXPLOSION_FIRE_ST;
                            AnimCounter <= EXPLOSION_DURATION;
                            ExplosionState <= 2'b01;
									 explosionFlag <= 1;
                        end
                        if (FuseCounter > 0) 
									SM_Motion <= START_OF_FRAME_ST; 
                    end
                end 

                EXPLOSION_FIRE_ST: begin
                    Xspeed <= 0; 
						  Yspeed <= 0;
						  explosionFlag <= 0;
                    if (startOfFrame) begin
                        if (AnimCounter > 0) 
									AnimCounter <= AnimCounter - 1;
                        else begin
                            SM_Motion <= EXPLOSION_SMOKE_ST;
                            AnimCounter <= EXPLOSION_DURATION;
                            ExplosionState <= 2'b10; 
                        end
                    end
                end

                EXPLOSION_SMOKE_ST: begin
                     if (startOfFrame) begin
                        if (AnimCounter > 0) 
									AnimCounter <= AnimCounter - 1;
                        else 
									SM_Motion <= IDLE_ST;
                    end
                end

                START_OF_FRAME_ST: begin 
                    if (hit_reg != 0) 
								Yspeed <= -Yspeed;
                    hit_reg <= 0;                        
                    SM_Motion <= POSITION_CHANGE_ST;
                end 

                POSITION_CHANGE_ST: begin 
                    Xposition <= Xposition + Xspeed; 
                    Yposition <= Yposition + Yspeed;
                    if (Yspeed < MAX_Y_SPEED) 
								Yspeed <= Yspeed - Y_ACCEL;
                    SM_Motion <= POSITION_LIMITS_ST;
                end

                POSITION_LIMITS_ST: begin 
                    if (Xposition < x_FRAME_LEFT) 
								Xposition <= x_FRAME_LEFT;
                    if (Xposition > x_FRAME_RIGHT) 
								Xposition <= x_FRAME_RIGHT; 
                    if (Yposition < y_FRAME_TOP) 
								Yposition <= y_FRAME_TOP;
                    if (Yposition > y_FRAME_BOTTOM) 
								Yposition <= y_FRAME_BOTTOM; 
                    if (SM_Motion == AIMING_ST) 
								SM_Motion <= AIMING_ST;
                    else 
								SM_Motion <= MOVING_ST;
                end
            endcase
        end 
    end 

    assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER;
    assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER;
    
    // OUTPUT CONVERSION:
    // Convert signed internal angle (-90 to +90) to standard 0-360 unsigned
    // -90 (Left) becomes 270
    //   0 (Down) becomes 0
    // +90 (Right) becomes 90
    assign Angle = (AnglePosition < 0) ? 
                   (AnglePosition / FIXED_POINT_MULTIPLIER + 360) : 
                   (AnglePosition / FIXED_POINT_MULTIPLIER);

endmodule