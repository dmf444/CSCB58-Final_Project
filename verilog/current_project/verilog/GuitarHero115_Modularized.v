/***************************************************************************************
*
*		This is the full Guitar Hero Game, simulated on 4 tracks.
*
***************************************************************************************/

module GuitarHero115_Modularized(KEY, LEDR, CLOCK_50, SW, LEDG, HEX0, HEX1, HEX2, HEX3, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B,);
	input [3:0] KEY;
	input CLOCK_50;
	input [12:0] SW;
	output [7:0] LEDR;
	output [4:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	 output          VGA_CLK;                //  VGA Clock
    output          VGA_HS;                 //  VGA H_SYNC
    output          VGA_VS;                 //  VGA V_SYNC
    output          VGA_BLANK_N;                //  VGA BLANK
    output          VGA_SYNC_N;             //  VGA SYNC
    output  [9:0]   VGA_R;                  //  VGA Red[9:0]
    output  [9:0]   VGA_G;                  //  VGA Green[9:0]
    output  [9:0]   VGA_B;                  //  VGA Blue[9:0]
	
	/////////////////////////////////////////////////////////////////
	//
	//			INITIAL SETUP DATA
	//
	/////////////////////////////////////////////////////////////////
	
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
	
	vga_display vga_stuff(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY[3:0]),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_R(VGA_R[9:0]),
        .VGA_G(VGA_G[9:0]),
        .VGA_B(VGA_B[9:0]),
		  .track1_in(vga_t1),
		  .track2_in(vga_t2),
		  .track3_in(vga_t3),
		  .track4_in(vga_t4)
    );
	 
	 wire vga_t1, vga_t2, vga_t3, vga_t4;
	 assign vga_t1 = track1_out[0];
	 assign vga_t2 = track2_out[0];
	 assign vga_t3 = track3_out[0];
	 assign vga_t4 = track4_out[0];
	
	/////////////////////////////////////////////////////////////////
	//
	//			COUNTERS for RAM and SHIFTERS
	//
	/////////////////////////////////////////////////////////////////
	wire [6:0] ram_pattern_lookup;
	counter_7bit track_pattern_selection(.INPUTCLOCK(shouldLoad), .reset_n(RESET_GAME), .counter(ram_pattern_lookup));
	
	/***** 4bit counter that keeps track of when the next memory load should be *****/
	wire shouldLoad;
	wire [2:0] counter;
	counter_4bit(.INPUTCLOCK(CLOCK_LINE), .reset_n(RESET_GAME), .counter(counter), .shouldLoad(shouldLoad));
	//assign LEDG[2:0] = counter;assign LEDG[3] = shouldLoad;
	
	
	/////////////////////////////////////////////////////////////////
	//
	//			RAM TRACKS AND SHIFTERS
	//
	/////////////////////////////////////////////////////////////////
	
	
	/*RAM DATA TRACK #1, PRELOADED FROM track1.mif*/
	wire [3:0] track1_out;
	ram_track1 track1(.address(ram_pattern_lookup),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track1_out));
	wire [3:0] track1_shift_out;
	shifters track1_shifters(.track_out(track1_out), .shouldLoad(shouldLoad), .CLOCK_LINE(CLOCK_LINE), .RESET_GAME(RESET_GAME), .shift_out(track1_shift_out));
	
	/*RAM DATA TRACK #2, PRELOADED FROM track2.mif*/
	wire [3:0] track2_out;
	ram_track2 track2(.address(ram_pattern_lookup),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track2_out));
	wire [3:0] track2_shift_out;
	shifters track2_shifters(.track_out(track2_out), .shouldLoad(shouldLoad), .CLOCK_LINE(CLOCK_LINE), .RESET_GAME(RESET_GAME), .shift_out(track2_shift_out));
	
	/*RAM DATA TRACK #3, PRELOADED FROM track3.mif*/
	wire [3:0] track3_out;
	ram_track3 track3(.address(ram_pattern_lookup),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track3_out));
	wire [3:0] track3_shift_out;
	shifters track3_shifters(.track_out(track3_out), .shouldLoad(shouldLoad), .CLOCK_LINE(CLOCK_LINE), .RESET_GAME(RESET_GAME), .shift_out(track3_shift_out));
	
	/*RAM DATA TRACK #4, PRELOADED FROM track4.mif*/
	wire [3:0] track4_out;
	ram_track4 track4(.address(ram_pattern_lookup),.clock(CLOCK_50),.data(empty_data),.wren(never_write),.q(track4_out));
	wire [3:0] track4_shift_out;
	shifters track4_shifters(.track_out(track4_out), .shouldLoad(shouldLoad), .CLOCK_LINE(CLOCK_LINE), .RESET_GAME(RESET_GAME), .shift_out(track4_shift_out));
	
	/////////////////////////////////////////////////////////////////
	//
	//			SCORE LOGICS
	//
	/////////////////////////////////////////////////////////////////
	
	wire correct_press1, correct_press2, correct_press3, correct_press4;
	xor(correct_press1, track1_shift_out[0], KEY[3]);
	xor(correct_press2, track2_shift_out[0], KEY[2]);
	xor(correct_press3, track3_shift_out[0], KEY[1]);
	xor(correct_press4, track4_shift_out[0], KEY[0]);
	
	wire increase_score;
	and(increase_score, correct_press1, correct_press2, correct_press3, correct_press4);
	score_keeper(CLOCK_LINE, increase_score, RESET_GAME | ~increase_score, HEX0, HEX1, HEX2, HEX3);
	
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
	
	//assign LEDR[7:4] = loadShiftOut;
	//assign LEDR[3:0] = straightShift;
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
