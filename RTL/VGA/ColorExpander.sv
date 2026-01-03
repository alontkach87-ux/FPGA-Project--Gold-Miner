module ColorExpander (
    input logic in_bit,
    output logic [7:0] out_color
);
    // Change 8'hFF to whatever color you want the '1' to be
    assign out_color = (in_bit) ? 8'hFF : 8'h00; 
endmodule