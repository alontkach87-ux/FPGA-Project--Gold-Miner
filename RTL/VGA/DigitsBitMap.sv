module DigitsBitMap (
    input logic clk,
    input logic resetN,
    input logic [10:0] offsetX,      // Provided by square_object
    input logic [10:0] offsetY,      // Provided by square_object
    input logic InsideRectangle,     // Provided by square_object
    
    input logic [9:0] NumValue,      // Value to display (0-999)
    
    output logic drawingRequest,
    output logic [7:0] RGBout
);

    // --- Configuration (16x16 Pixel Doubled) ---
    localparam int DIGIT_WIDTH  = 16; 
    localparam int DIGIT_HEIGHT = 16;
    localparam int SPACING      = 4;
    localparam logic [7:0] TEXT_COLOR = 8'h1C; // Black

    // --- Font Definition (8x8) ---
    logic [0:7][0:7] font [0:9];
    
    initial begin
        font[0] = '{8'h3C, 8'h66, 8'h66, 8'h66, 8'h66, 8'h66, 8'h66, 8'h3C}; 
        font[1] = '{8'h18, 8'h38, 8'h18, 8'h18, 8'h18, 8'h18, 8'h18, 8'h3C}; 
        font[2] = '{8'h3C, 8'h66, 8'h06, 8'h0C, 8'h18, 8'h30, 8'h60, 8'h7E}; 
        font[3] = '{8'h3C, 8'h66, 8'h06, 8'h1C, 8'h06, 8'h06, 8'h66, 8'h3C}; 
        font[4] = '{8'h0C, 8'h1C, 8'h3C, 8'h6C, 8'hCC, 8'hFE, 8'h0C, 8'h0C}; 
        font[5] = '{8'h7E, 8'h60, 8'h60, 8'h7C, 8'h06, 8'h06, 8'h66, 8'h3C}; 
        font[6] = '{8'h3C, 8'h66, 8'h60, 8'h7C, 8'h66, 8'h66, 8'h66, 8'h3C}; 
        font[7] = '{8'h7E, 8'h06, 8'h0C, 8'h18, 8'h30, 8'h30, 8'h30, 8'h30}; 
        font[8] = '{8'h3C, 8'h66, 8'h66, 8'h3C, 8'h66, 8'h66, 8'h66, 8'h3C}; 
        font[9] = '{8'h3C, 8'h66, 8'h66, 8'h3E, 8'h06, 8'h06, 8'h66, 8'h3C}; 
    end

    // --- Calculations ---
    logic [3:0] hundreds, tens, ones;
    logic [3:0] currentDigitToDraw;
    int bitOffset; 

    assign hundreds = (NumValue / 100) % 10;
    assign tens     = (NumValue / 10) % 10;
    assign ones     = NumValue % 10;

    always_comb begin
        // Defaults
        drawingRequest = 0;
        RGBout = 0;
        
        currentDigitToDraw = 0;
        bitOffset = 0;

        if (InsideRectangle) begin
            
            // Check Vertical Bounds (0 to 15)
            if (offsetY >= 0 && offsetY < DIGIT_HEIGHT) begin
                
                // --- Hundreds Place (0 to 15) ---
                if (offsetX >= 0 && offsetX < DIGIT_WIDTH) begin
                    // ONLY draw if we have a hundreds value (NumValue >= 100)
                    if (NumValue >= 100) begin
                        currentDigitToDraw = hundreds;
                        bitOffset = offsetX;
                        // Pixel Doubling Logic: Read index >> 1
                        drawingRequest = font[currentDigitToDraw][offsetY >> 1][bitOffset >> 1];
                    end
                end
                
                // --- Tens Place (20 to 35) ---
                else if (offsetX >= (DIGIT_WIDTH + SPACING) && offsetX < (2*DIGIT_WIDTH + SPACING)) begin
                    // ONLY draw if we have a tens value (NumValue >= 10)
                    if (NumValue >= 10) begin
                        currentDigitToDraw = tens;
                        bitOffset = offsetX - (DIGIT_WIDTH + SPACING);
                        drawingRequest = font[currentDigitToDraw][offsetY >> 1][bitOffset >> 1];
                    end
                end
                
                // --- Ones Place (40 to 55) ---
                else if (offsetX >= (2*DIGIT_WIDTH + 2*SPACING) && offsetX < (3*DIGIT_WIDTH + 2*SPACING)) begin
                    // ALWAYS draw the ones place (so 0 appears as "0")
                    currentDigitToDraw = ones;
                    bitOffset = offsetX - (2*DIGIT_WIDTH + 2*SPACING);
                    drawingRequest = font[currentDigitToDraw][offsetY >> 1][bitOffset >> 1];
                end
            end
        end
        
        if (drawingRequest)
            RGBout = TEXT_COLOR;
    end

endmodule