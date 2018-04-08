/*EXPECTED OUTPUT OF THIS TEST:
This should act like the game, without the final score setup attached.
*/

module GuitarHero_Modularized(KEY, LEDR, CLOCK_50, SW, LEDG, HEX0, HEX1, HEX2, HEX3);
	input [3:0] KEY;
	input CLOCK_50;
	input [12:0] SW;
	output [7:0] LEDR;
	output [4:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
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
	
	wire [3:0] track1_shift_out;
	shifters track1_shifters(.track_out(track1_out), .shouldLoad(shouldLoad), .CLOCK_LINE(CLOCK_LINE), .RESET_GAME(RESET_GAME), .shift_out(track1_shift_out));
	assign LEDR[3:0] = track1_shift_out;
	
	wire correct_press1;
	xor(correct_press1, track1_shift_out[0], KEY[3]);
	score_keeper(CLOCK_LINE, correct_press1, RESET_GAME | ~correct_press1, HEX0, HEX1, HEX2, HEX3);
	
endmodule

module shifters(track_out, shouldLoad, CLOCK_LINE, RESET_GAME, shift_out);
	input [3:0] track_out;
	input shouldLoad;
	input CLOCK_LINE;
	input RESET_GAME;
	output [3:0] shift_out;
	/***************TOP SET OF SHIFTS, RESPONSIBLE FOR LOADING FROM RAM*****************/
	wire [3:0] loadShiftOut;
	shifterbit loadShift7(.OUT(loadShiftOut[3]),.IN(never_write),.LOAD(track_out[3]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift6(.OUT(loadShiftOut[2]),.IN(loadShiftOut[3]),.LOAD(track_out[2]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift5(.OUT(loadShiftOut[1]),.IN(loadShiftOut[2]),.LOAD(track_out[1]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbit loadShift4(.OUT(loadShiftOut[0]),.IN(loadShiftOut[1]),.LOAD(track_out[0]),.SHIFT(~shouldLoad),.LOAD_N(~shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	
	
	/***************BOTTOM SET OF SHIFTS, ONLY SHIFTS*****************/
	wire [3:0] straightShift;
	shifterbitNL loadShift3(.OUT(straightShift[3]),.IN(loadShiftOut[0]),.SHIFT(~shouldLoad | shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift2(.OUT(straightShift[2]),.IN(straightShift[3]),.SHIFT(~shouldLoad | shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift1(.OUT(straightShift[1]),.IN(straightShift[2]),.SHIFT(~shouldLoad | shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	shifterbitNL loadShift0(.OUT(straightShift[0]),.IN(straightShift[1]),.SHIFT(~shouldLoad | shouldLoad),.CLK(CLOCK_LINE),.RESET_N(~RESET_GAME));
	
	assign shift_out = straightShift;
	
endmodule

module score_keeper(clock, increment, reset, HEX0, HEX1, HEX2, HEX3);
	input clock;
	input increment;
	input reset;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	wire [3:0] input_H0, input_H1, input_H2, input_H3;
	counter_scoreboard csb(.INPUTCLOCK(clock), .reset_n(reset), .counter1(input_H0), .counter2(input_H1), .counter3(input_H2), .counter4(input_H4));
	
	hexdisplay hx0(.hex_digit(input_H0), .OUT(HEX0[6:0]));
	hexdisplay hx1(.hex_digit(input_H1), .OUT(HEX1[6:0]));
	hexdisplay hx2(.hex_digit(input_H2), .OUT(HEX2[6:0]));
	hexdisplay hx3(.hex_digit(input_H3), .OUT(HEX3[6:0]));
endmodule
