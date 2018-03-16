// Part 2 skeleton

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY, LEDR,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output	  [3:0] LEDR;

	// Declare your inputs and outputs here
	wire [6:0] x2;

	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [6:0] x;
	wire [6:0] y;
	wire writeEn;
	wire ld_out_x;
	wire ld_out_y;
	wire ld_x;
	wire ld_y;
	wire [1:0] select_x;
	assign x = {1'b0, x2};
	
	assign colour = SW[9:7];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(draw),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
    
    // Instansiate FSM control
	control C0(
        .clk(CLOCK_50),
        .resetn(resetn),
        
        .go(KEY[3]),
		  .start(KEY[1]),
        
        .ld_out_x(ld_out_x), 
		  .ld_out_y(ld_out_y), 
        .ld_x(ld_x),
        .ld_y(ld_y), 
        .ld_r(writeEn),
        
        .select_x(select_x),
    );

    // Instansiate datapath
    datapath D0(
        .clk(CLOCK_50),
        .resetn(resetn),

        .ld_out_x(ld_out_x), 
		  .ld_out_y(ld_out_y), 
        .ld_x(ld_x),
        .ld_y(ld_y), 
        .ld_r(writeEn),
        
        .select_x(select_x),

        .data_in(SW[6:0]),
        .data_result_x(x2),
		  .data_result_y(y)
    );
    
endmodule

module control(
    input clk,
    input resetn,
    input go,
    input start,

    output reg  ld_x, ld_y, ld_r, ld_out_x, ld_out_y,
    output reg [1:0]  select_x
    );

    reg [5:0] current_state, next_state;
	 reg [2:0] counter;
    
    localparam  S_LOAD_X        = 5'd0,
                S_LOAD_X_WAIT   = 5'd1,
                S_LOAD_Y        = 5'd2,
                S_LOAD_Y_WAIT   = 5'd3,
                S_START   	     = 5'd4,
                S_CYCLE_0       = 5'd5,
                S_CYCLE_1       = 5'd6,
                S_CYCLE_2       = 5'd7,
					 S_CYCLE_3		  = 5'd8,
					 S_CYCLE_4		  = 5'd9,
					 S_CYCLE_5		  = 5'd10,
					 S_CYCLE_6		  = 5'd11,
					 S_CYCLE_7		  = 5'd12,
					 S_CYCLE_8		  = 5'd13,
					 S_CYCLE_9		  = 5'd14,
					 S_CYCLE_10		  = 5'd15,
					 S_CYCLE_11		  = 5'd16,
					 S_CYCLE_12		  = 5'd17,
					 S_CYCLE_13		  = 5'd18,
					 S_CYCLE_14		  = 5'd19,
					 S_CYCLE_15		  = 5'd20;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = start ? S_LOAD_Y_WAIT : S_START; // Loop in current state until go signal goes low
					 S_START: next_state = S_CYCLE_0;
					 S_CYCLE_0: next_state = S_CYCLE_1;
					 S_CYCLE_1: next_state = S_CYCLE_2;
					 S_CYCLE_2: next_state = S_CYCLE_3;
					 S_CYCLE_3: next_state = S_CYCLE_4;
					 S_CYCLE_4: next_state = S_CYCLE_5;
					 S_CYCLE_5: next_state = S_CYCLE_6;
					 S_CYCLE_6: next_state = S_CYCLE_7;
					 S_CYCLE_7: next_state = S_CYCLE_8;
					 S_CYCLE_8: next_state = S_CYCLE_9;
					 S_CYCLE_9: next_state = S_CYCLE_10;
					 S_CYCLE_10: next_state = S_CYCLE_11;
					 S_CYCLE_11: next_state = S_CYCLE_12;
					 S_CYCLE_12: next_state = S_CYCLE_13;
					 S_CYCLE_13: next_state = S_CYCLE_14;
					 S_CYCLE_14: next_state = S_CYCLE_15;
					 S_CYCLE_15: next_state = S_START;
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_out_x = 1'b0;
        ld_out_y = 1'b0;
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_r = 1'b0;
        select_x = 2'b00;

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                ld_out_x = 1'b0;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                ld_out_y = 1'b0;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                end
				S_START: begin
					 ld_r = 1'b1;
                ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
					 end
            S_CYCLE_0: begin
                ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_1: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
				S_CYCLE_2: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_3: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
					 ld_r = 1'b1;
					 select_x = 2'b10;
            	end
				S_CYCLE_4: begin
                ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_5: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
				S_CYCLE_6: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_7: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
					 ld_r = 1'b1;
					 select_x = 2'b10;
            	end
				S_CYCLE_8: begin
                ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_9: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
				S_CYCLE_10: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_11: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
					 ld_r = 1'b1;
					 select_x = 2'b10;
            	end
				S_CYCLE_12: begin
                ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_13: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
				S_CYCLE_14: begin
					 ld_y = 1'b1;
                ld_out_y = 1'b1;
                ld_x = 1'b1;
                ld_out_x = 1'b1;
                ld_r = 1'b1;
                select_x = 2'b01;
            	end
            S_CYCLE_15: begin
					ld_r = 1'b1;
					ld_y = 1'b1;
               ld_out_y = 1'b0;
               ld_x = 1'b1;
               ld_out_x = 1'b0;
					 
					 select_x = 2'b11;
            	end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [6:0] data_in,
    input ld_out_x, ld_out_y,
    input ld_x, ld_y,
    input ld_r,
    input [1:0] select_x,
    output reg [6:0] data_result_x,
    output reg [6:0] data_result_y
    );
    
	 wire delayenable;
	 
    // input registers
    reg [6:0] x, y;

    // output of the x and y
    reg [6:0] out_x, out_y, out;
    
    // Registers x, y with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 7'b0000000; 
            y <= 7'b0000000; 
        end
        else begin
            if(ld_x)
                x <= ld_out_x ? out_x : data_in; // load out_x if ld_out signal is high, otherwise load from data_in
            if(ld_y)
                y <= ld_out_y ? out_y : data_in; // load out_y if ld_out signal is high, otherwise load from data_in
        end
    end
 
    // Output result register0
    always@(posedge clk) begin
        if(!resetn) begin
            data_result_x <= 7'b0000000;
            data_result_y <= 7'b0000000; 
        end
        else 
            if(ld_r) begin
                data_result_x <= out_x;
                data_result_y <= out_y;
	    end
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (select_x)
            2'd0: begin
                out_x = x;
                out_y = y;
						end
            2'd1: begin
                out_x = x + 7'd1;
                out_y = y;
						end
            2'd2: begin
            	 out_x = x - 7'd3;
                out_y = y + 7'd1;
						end
				2'd3: begin
						out = out + 7'd1;
						out_x = x;
						out_y = data_in + out;
						end
            default: begin
					 out_x = 7'b0000000;
                out_y = 7'b0000000;
					end
        endcase
    end
	 
	 // Counters
	 DelayCounter(
			.clock(clk),
			.resetn(resetn),
			.enable(delayenable)
	);
	
	FrameCounter (
			.clock(delayenable),
			.resetn(resetn),
			.enable(enable)
	);
    
endmodule

module DelayCounter (
	input clock,
	input resetn,
	output enable
	);
	reg [28:0] q;

	assign enable = (q == 28'd0) ? 1 : 0;
	
	always @(posedge clock, negedge resetn)
	begin
		if (resetn == 1'b0)
			q <= (28'd5_000_000 - 1);
		else if (q == 0)
			q <= (28'd5_000_000 - 1);
		else
			q <= (q - 1'b1);
	end
endmodule

module FrameCounter(
	input clock,
	input resetn,
	output enable
	);
	reg [4:0] q;

	assign enable = (q == 4'd0) ? 1 : 0;
	
	always @(posedge clock, negedge resetn)
	begin
		if (resetn == 1'b0)
			q <= (4'd15 - 1);
		else if (q == 0)
			q <= (4'd15 - 1);
		else
			q <= (q - 1'b1);
	end

endmodule
