// Part 2 skeleton

module gameTest
	(
		CLOCK_50,						//	On Board 50 MHz
        KEY, LEDR,
        SW,
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

	output	[3:0]   LEDR;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
    wire    [6:0]   x2;
	wire            resetn;
	wire    [2:0]   colour;
	wire    [6:0]   x;
	wire    [6:0]   y;

    assign resetn = KEY[0];
	assign x      = {1'b0, x2};

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
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

    // Instansiate datapath
    datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .x(x2),
		.y(y),
        .color(colour)
    );
    
endmodule


module datapath(
    input clk,
    input resetn,
    output reg [6:0] x,
    output reg [6:0] y,
    output reg [2:0] color
    );

    reg [6:0]  x_state = 7'd0;
    reg [6:0]  y_state = 7'd0;
    reg [27:0] counter = 28'd0;
    
    always@(posedge clk) begin
        if(!resetn) begin
            x_state <= 7'd0;
            y_state <= 7'd0;
            counter <= 28'd0;
        end
        else begin
            if (counter < 28'd20000020) begin
                if (counter < 28'd17 && counter > 28'd0) begin
						x <= x + 7'd1;
                    if (x == 7'd3) begin
								y <= y + 7'd1;
                        x <= 7'd0;
							end
                    color <= 3'b100;
                end
                if (counter >= 28'd10000000) begin
					 if (counter == 28'd10000000)
						y <= y_state;
                    if (counter < 28'd10000017 && counter > 28'd10000000) begin
                      x <= x + 7'd1;
                        if (x == 7'd3) begin
								y <= y + 7'd1;
                        x <= 7'd0;
							end
                        color <= 3'b000;
                    end
                    if (counter == 28'd10000018) begin
                        x_state <= x_state + 7'd1;
                        y_state <= y_state + 7'd1;
                    end
                    if (counter == 28'd4000019)
                        y <= y_state;
								x <= 7'd0;
                end
                counter = counter + 1;
            end else begin
                counter <= 11'd0;
            end
        end
    end
    
endmodule
