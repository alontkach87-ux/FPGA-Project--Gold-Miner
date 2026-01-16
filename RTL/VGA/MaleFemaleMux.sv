module MaleFemaleMux (
    input  logic clk,
    input  logic resetN,
    input  logic flag,
    output logic out
);

    logic state;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            state <= 1'b1; // Default is 1 - Female
        end
        else begin
            if (flag == 1'b1 && state == 1'b1) begin //Male
                state <= 1'b0;
            end
            else if (flag == 1'b1 && state == 1'b0) begin
                state <= 1'b1;
            end
        end
    end

    assign out = state;

endmodule