module mif_mux(
	input logic clk,
	input logic resetN,
	input logic shopDR,
	input logic victoryDR,
	input logic gameOverDR,
	input logic startDR,
	input logic [1:0] level,
	input logic [7:0] MIF1_VGA,
	input logic [7:0] MIFvictory_VGA,
	input logic [7:0] MIFgameover_VGA,
	input logic [7:0] MIFshop_VGA,
	input logic [7:0] MIFstart_VGA,
	output logic [7:0] MIF_VGA
);

always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
			MIF_VGA	<= MIF1_VGA;
	end
	else begin
		if(shopDR == 1'b1)
			MIF_VGA <= MIFshop_VGA;
		else if(victoryDR == 1'b1)
			MIF_VGA <= MIFvictory_VGA;
		else if(gameOverDR == 1'b1)
			MIF_VGA <= MIFgameover_VGA;
		else if(startDR == 1'b1)
			MIF_VGA <= MIFstart_VGA;
		else begin
			MIF_VGA <= MIF1_VGA;
		end
	end
end
endmodule