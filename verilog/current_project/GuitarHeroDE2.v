/*EXPECTED OUTPUT OF THIS TEST:
This should act like the game, without the final score setup attached.
*/

module TestGuitarHero2(KEY, LEDR, CLOCK_50, SW, LEDG);
	input [3:0] KEY;
	input CLOCK_50;
	input [12:0] SW;
	output [7:0] LEDR;
	output [4:0] LEDG;
	
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
	RDF tf0(.enable(1'b1), .clkin(CLOCK_50), .clkout(CLOCK_LINE));
	//assign CLOCK_LINE = ~KEY[0];
	
	/*RAM DATA TRACK #1, PRELOADED FROM  .mif*/
	wire [3:0] track1_out;
	ram_track1 track1(.address(ram_pattern_lookup),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track1_out));
	wire [6:0] ram_pattern_lookup;
	counter_7bit track_pattern_selection(.INPUTCLOCK(shouldLoad), .reset_n(RESET_GAME), .counter(ram_pattern_lookup));
	
	
	/***** 4bit counter that keeps track of when the next memory load should be *****/
	wire shouldLoad;
	wire [2:0] counter;
	counter_4bit(.INPUTCLOCK(CLOCK_LINE), .reset_n(RESET_GAME), .counter(counter), .shouldLoad(shouldLoad));
	//assign LEDG[2:0] = counter;assign LEDG[3] = shouldLoad;
	
	
	/***************TOP SET OF SHIFTS, RESPONSIBLE FOR LOADING FROM RAM*****************/
	wire [3:0] loadShiftOut;
	shifterbit loadShift7(.OUT(loadShiftOut[3]),.IN(never_write),.LOAD(track1_out[3]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift6(.OUT(loadShiftOut[2]),.IN(loadShiftOut[3]),.LOAD(track1_out[2]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift5(.OUT(loadShiftOut[1]),.IN(loadShiftOut[2]),.LOAD(track1_out[1]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift4(.OUT(loadShiftOut[0]),.IN(loadShiftOut[1]),.LOAD(track1_out[0]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	
	
	/***************BOTTOM SET OF SHIFTS, ONLY SHIFTS*****************/
	wire [3:0] straightShift;
	shifterbitNL loadShift3(.OUT(straightShift[3]),.IN(loadShiftOut[0]),.SHIFT(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift2(.OUT(straightShift[2]),.IN(straightShift[3]),.SHIFT(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift1(.OUT(straightShift[1]),.IN(straightShift[2]),.SHIFT(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift0(.OUT(straightShift[0]),.IN(straightShift[1]),.SHIFT(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	
	
	
	assign LEDR[7:4] = loadShiftOut;
	assign LEDR[3:0] = straightShift;
	
endmodule
