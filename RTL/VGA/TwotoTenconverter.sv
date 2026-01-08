module TwotoTenconverter(

	input logic [1:0] in,
	output logic [9:0] out

);

	assign out = {8'b00000000,in};

endmodule