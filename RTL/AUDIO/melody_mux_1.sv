module melody_mux_1 (
	input logic clk ,
	input logic resetN ,
	input logic explosion,
	input logic treasureAdded,
	input logic launch,
	input logic gameStart,
	input logic gameOver,
	input logic victory,
	output logic enable,
	output logic [2:0] select
);

	always_comb begin
		if(victory == 1'b1) begin
			select = 5;
			enable = 1;
		end
		else if(gameOver == 1'b1) begin
			select = 4;
			enable = 1;
		end
		else if(gameStart == 1'b1) begin
			select = 3;
			enable = 1;
		end
		else if(launch == 1'b1) begin
			select = 2;
			enable = 1;
		end
		else if(treasureAdded == 1'b1) begin //if bomb explodes on treasure, different sound than if bomb explodes without treasure
			select = 1;
			enable = 1;
		end
		else if(explosion == 1'b1) begin
			select = 0;
			enable = 1;
		end
		else begin 
			select = 6;
			enable = 0;
		end
	end
endmodule