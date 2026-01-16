module MaleFemaleMux (
    input logic clk,
    input logic resetN,
    input logic flag, // input from game controller
    output logic state // 1 for female, 0 for male
);

    logic flag_delayed; // History register

    always_ff @(posedge clk or negedge resetN) begin
        if(!resetN) begin
            state <= 1'b1;       // Default: Female
            flag_delayed <= 1'b0;
        end
        else begin
            flag_delayed <= flag; // Remember value from previous cycle
            
            // RISING EDGE DETECTOR:
            if(flag == 1'b1 && flag_delayed == 1'b0) begin
                state <= !state; // Toggle EXACTLY once
            end
        end
    end

endmodule