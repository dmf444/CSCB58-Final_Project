/*EXPECTED OUTPUT OF THIS TEST:
Upon running this on a DE2-115 Board, this should create a
RAM block with default values, and load 1010 into the LEDR[7:4]
*/

module TestGuitarHero(KEY, LEDR, CLOCK_50);
	input [3:0] KEY;
	input CLOCK_50;
	output [7:0] LEDR;
	
	wire [3:0] empty_data;
	assign empty_data = 4'b0000;
	wire never_write;
	assign never_write = 1'b0;
	
	wire [3:0] track1_out;
	ram32x4_track1 track1(
		.address(5'b00000),
		.clock(CLOCK_50),
		.data(empty_data),
		.wren(never_write),
		.q(track1_out)
	);
	
	assign LEDR[7:4] = track1_out;
	
endmodule
