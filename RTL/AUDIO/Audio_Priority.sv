module Audio_Priority (
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,
    
    // Inputs
    input  logic ExplosionState,  
    input  logic treasureHit,  
    
    // Outputs to Melody Mux
    output logic ExplosionAudio,
    output logic TreasureAudio
);

    // 1. PULSE STRETCHER (For the Treasure)
    // ----------------------------------------------------------------
    // We need to catch the tiny 'treasureHit' pulse and hold it
    // high long enough for the audio to play (e.g., 60 frames = 1 sec).
    logic [5:0] priority_timer; 

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            priority_timer <= 0;
        end 
		  else begin
            // Asynchronously catch the pulse during the frame scan
            if (treasureHit) begin
                priority_timer <= 60; 
            end 
            // Count down at the start of every frame
            else if (startOfFrame && priority_timer > 0) begin
                priority_timer <= priority_timer - 1;
            end
        end
    end

    // 2. EXPLOSION DELAY (For clean synchronization)
    // ----------------------------------------------------------------
    // We delay the explosion signal by 1 frame. 
    // This gives the collision pulse time to arrive (mid-frame) 
    // and set the priority timer BEFORE the explosion sound is allowed through.
    logic explosion_delayed;

    always_ff @(posedge startOfFrame or negedge resetN) begin
        if (!resetN) 
            explosion_delayed <= 0;
        else 
            explosion_delayed <= ExplosionState;
    end

    // 3. PRIORITY OUTPUT LOGIC
    // ----------------------------------------------------------------
    
    // Treasure wins if the timer is running
    assign TreasureAudio = (priority_timer > 0);

    // Explosion is allowed ONLY if:
    // a. The Delayed Explosion signal is High
    // b. AND the Treasure timer is NOT running
    assign ExplosionAudio = explosion_delayed && (priority_timer == 0);

endmodule