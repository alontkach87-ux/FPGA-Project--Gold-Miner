// (c) Technion IIT, The Faculty of Electrical and Computer Engineering, 2025
//
//  GAME VERSION - MODIFIED
//

module JukeBox1 (
    // Declare wires and regs :
    input logic [2:0] melodySelect,       // CHANGED: Reduced to 3 bits for 6 cases
    input logic [4:0] noteIndex,          // serial number of current note
 
    output logic [3:0] tone,              // index to toneDecoder
    output logic [3:0] note_length,       // length of notes, in beats
    output logic silenceOutN              // a silence note: disable sound
);

    localparam MaxMelodyLength = 6'h32;   // maximum melody length

    // ************** frequencies: *********************************************
    typedef enum logic [3:0] {
        do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, silence 
    } musicNote;
    // *************************************************************************
      
    musicNote frq[(MaxMelodyLength-1'b1):0]; // array of frequency indices
    logic [3:0] len[(MaxMelodyLength-1'b1):0]; // array of note lengths

    assign silenceOutN = !(tone == silence); // disable sound if note is "silence"

    always_comb begin	 
        frq = '{default: silence}; // Default to silence to avoid latches
        len = '{default: 0}; 

        case (melodySelect)  
            
            //---------------------------------------------------------
            // Case 0: Explosion (Fast descending chaotic scale)
            //---------------------------------------------------------
            0: begin
                frq[0] = re_H;  len[0] = 1; 
                frq[1] = si;    len[1] = 1; 
                frq[2] = sol;   len[2] = 1; 
                frq[3] = mi;    len[3] = 1; 
                frq[4] = do_;   len[4] = 2; // Low thud at end
                frq[5] = do_;   len[5] = 0; // End
            end 

            //---------------------------------------------------------
            // Case 1: Treasure Added (High "Bling" sound)
            //---------------------------------------------------------
            1: begin
                frq[0] = si;    len[0] = 1; 
                frq[1] = re_H;  len[1] = 4; // Long ring
                frq[2] = do_;   len[2] = 0; // End
            end
            
            //---------------------------------------------------------
            // Case 2: Launch (Rising "Whoosh")
            //---------------------------------------------------------
            2: begin
                frq[0] = re;    len[0] = 1; 
                frq[1] = fa;    len[1] = 1; 
                frq[2] = la;    len[2] = 1; 
                frq[3] = do_H;  len[3] = 2; 
                frq[4] = do_;   len[4] = 0; // End
            end 

            //---------------------------------------------------------
            // Case 3: Game Start (Short Fanfare)
            //---------------------------------------------------------
            3: begin
                frq[0] = sol;   len[0] = 2; 
                frq[1] = do_H;  len[1] = 6; 
                frq[2] = do_;   len[2] = 0; // End
            end 

            //---------------------------------------------------------
            // Case 4: Game Over (Sad descending tritone)
            //---------------------------------------------------------
            4: begin
                frq[0] = do_H;  len[0] = 3; 
                frq[1] = sol;   len[1] = 3; 
                frq[2] = faD;   len[2] = 3; 
                frq[3] = fa;    len[3] = 8; // Long sad note
                frq[4] = do_;   len[4] = 0; // End
            end

            //---------------------------------------------------------
            // Case 5: Victory (Happy Arpeggio)
            //---------------------------------------------------------
            5: begin
                frq[0] = do_;   len[0] = 2; 
                frq[1] = mi;    len[1] = 2; 
                frq[2] = sol;   len[2] = 2; 
                frq[3] = do_H;  len[3] = 8; // Victory hold
                frq[4] = do_;   len[4] = 0; // End
            end

            //---------------------------------------------------------
            // Default: Silence
            //---------------------------------------------------------
            default: begin
                frq[0] = silence; len[0] = 1;
                frq[1] = silence; len[1] = 0;
            end

        endcase
    end 
 
    // Extract outputs 
    assign tone = frq[noteIndex];
    assign note_length = len[noteIndex]; 
 
endmodule