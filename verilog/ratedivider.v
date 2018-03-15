module Ratedivider (
	input clock,
	input resetn,
	output enable
	);
	reg [28:0] q;

	assign enable = (q == 28'd0) ? 1 : 0;
	
	always @(posedge clock, negedge resetn)
	begin
		if (resetn == 1'b0)
			q <= (28'd50_000 - 1);
		else if (q == 0)
			q <= (28'd50_000 - 1);
		else
			q <= (q - 1'b1);
	end
endmodule
