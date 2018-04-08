/*EXPECTED OUTPUT OF THIS TEST:
Upon running this on a DE2-115 Board, the LEDR[7:4] should light up 1010, and each
clock pulse of KEY[0] should shift the data over. Once 0000 is in the lights, the RAM block
should reload the shifter with the same values.
*/

module Test2GuitarHero(KEY, LEDR, CLOCK_50, SW);
	input [3:0] KEY;
	input CLOCK_50;
	input [12:0] SW;
	output [7:0] LEDR;
	
	//PLACEBO FOR DATASELECTION COUNTER
	wire [3:0] empty_data;
	assign empty_data = 4'b0000;
	
	//DEFAULT FOR NEVER ON WIRE
	wire never_write;
	assign never_write = 1'b0;
	
	//EASE OF ACCESS WIRING
	wire RESET_GAME;
	assign RESET_GAME = SW[12];
	
	//NEED TO CHANGE THE GAME CLOCK SPEED/GO MANUAL? CLICK HERE!
	wire CLOCK_LINE;
	assign CLOCK_LINE = KEY[0];
	
	/*RAM DATA TRACK #1, PRELOADED FROM  .mif*/
	wire [3:0] track1_out;
	ram32x4_track1 track1(.address(5'b00000),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track1_out));
	
	/***** 4bit counter that keeps track of when the next memory load should be *****/
	wire shouldLoad;
	wire [1:0] counter;
	counter_4bit(.INPUTCLOCK(CLOCK_LINE), .reset_n(RESET_GAME), .counter(counter), .shouldLoad(shouldLoad));
	
	wire [3:0] loadShiftOut;
	shifterbit loadShift3(.OUT(loadShiftOut[3]),.IN(never_write),.LOAD(track1_out[3]),.SHIFT(CLOCK_LINE),.LOAD_N(shouldLoad),.CLK(CLOCK_LINE),.RESET_N(RESET_GAME));
	shifterbit loadShift2(.OUT(loadShiftOut[2]),.IN(loadShiftOut[3]),.LOAD(track1_out[2]),.SHIFT(CLOCK_LINE),.LOAD_N(shouldLoad),.CLK(CLOCK_LINE),.RESET_N(RESET_GAME));
	shifterbit loadShift1(.OUT(loadShiftOut[1]),.IN(loadShiftOut[2]),.LOAD(track1_out[1]),.SHIFT(CLOCK_LINE),.LOAD_N(shouldLoad),.CLK(CLOCK_LINE),.RESET_N(RESET_GAME));
	shifterbit loadShift0(.OUT(loadShiftOut[0]),.IN(loadShiftOut[1]),.LOAD(track1_out[0]),.SHIFT(CLOCK_LINE),.LOAD_N(shouldLoad),.CLK(CLOCK_LINE),.RESET_N(RESET_GAME));
	
	assign LEDR[7:4] = loadShiftOut;
	
endmodule
