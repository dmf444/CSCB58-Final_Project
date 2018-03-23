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
		  .light(LEDR[0]),
        .x(x2),
		.y(y),
        .color(colour)
    );
    
endmodule


module datapath(
    input clk,
    input resetn,
	 output reg light,
    output reg [6:0] x,
    output reg [6:0] y,
    output reg [2:0] color
    );

	 reg [6:0]  x1 = 7'd0;
    reg [6:0]  y1 = 7'd0;
	 reg [6:0]  x2 = 7'd70;
    reg [6:0]  y2 = 7'd0;
	 reg [6:0]  x3 = 7'd140;
    reg [6:0]  y3 = 7'd0;
	 reg [6:0]  x4 = 7'd210;
    reg [6:0]  y4 = 7'd0;
	 reg [6:0]  x_state = 7'd0;
    reg [6:0]  y_state = 7'd0;
	 reg [6:0]  x2_state = 7'd0;
    reg [6:0]  y2_state = 7'd0;
	 reg [6:0]  x3_state = 7'd0;
    reg [6:0]  y3_state = 7'd0;
	 reg [6:0]  x4_state = 7'd0;
    reg [6:0]  y4_state = 7'd0;
    reg [27:0] counter = 28'd0;
    
    always@(posedge clk) begin
        if(!resetn) begin
            x_state <= 7'd0;
            y_state <= 7'd0;
            counter <= 28'd0;
        end
        else begin
            if (counter < 28'd1000514) begin
                if (counter < 28'd128) begin
					 x <= x1;
					 y <= y1;
					 color <= 3'b100;
					   if (counter != 28'd0) 
							x1 <= x1 + 7'd1;
                    if (x1 == 7'd15) begin
								y1 <= y1 + 7'd1;
                        x1 <= 7'd0;
							end
                end
					 if (counter == 28'd128) begin
						y1 <= y_state;
						x1 <= 7'd0;
						end
						if (counter < 28'd256 && counter >= 28'd128) begin
						x <= x2;
					 y <= y2;
					 color <= 3'b110;
					   if (counter != 28'd128) 
							x2 <= x2 + 7'd1;
                    if (x2 == 7'd85) begin
								y2 <= y2 + 7'd1;
                        x2 <= 7'd70;
							end
                end
					 if (counter == 28'd256) begin
						y2 <= y2_state;
						x2 <= 7'd70;
						end
						if (counter < 28'd384 && counter >= 28'd256) begin
						x <= x3;
					 y <= y3;
					 color <= 3'b111;
					   if (counter != 28'd256) 
							x3 <= x3 + 7'd1;
                    if (x3 == 7'd155) begin
								y3 <= y3 + 7'd1;
                        x3 <= 7'd140;
							end
                end
					 if (counter == 28'd384) begin
						y3 <= y3_state;
						x3 <= 7'd140;
						end
						if (counter < 28'd512 && counter >= 28'd384) begin
						x <= x4;
					 y <= y4;
					 color <= 3'b011;
					   if (counter != 28'd384) 
							x4 <= x4 + 7'd1;
                    if (x4 == 7'd225) begin
								y4 <= y4 + 7'd1;
                        x4 <= 7'd210;
							end
                end
					 if (counter == 28'd512) begin
						y4 <= y4_state;
						x4 <= 7'd210;
						end
					// DELETE
                if (counter >= 28'd1000000) begin
                    if (counter < 28'd1000128) begin
						  x <= x1;
					 y <= y1;
						    color <= 3'b000;
							 if (counter != 28'd1000000)
							   x1 <= x1 + 7'd1;
							 if (x1 == 7'd15) begin
								y1 <= y1 + 7'd1;
                        x1 <= 7'd0;
							end
                    end
                    if (counter == 28'd1000128) begin
                        x_state <= x_state + 7'd1;
                        y_state <= y_state + 7'd1;
                    end
                    if (counter == 28'd1000129) begin
                        y1 <= y_state;
								x1 <= 7'd0;
								end
								if (counter < 28'd1000256 && counter >= 28'd1000128) begin
								x <= x2;
					 y <= y2;
						    color <= 3'b000;
							 if (counter != 28'd1000128)
							   x2 <= x2 + 7'd1;
							 if (x2 == 7'd85) begin
								y2 <= y2 + 7'd1;
                        x2 <= 7'd70;
							end
                    end
                    if (counter == 28'd1000256) begin
                        x2_state <= x2_state + 7'd1;
                        y2_state <= y2_state + 7'd1;
                    end
                    if (counter == 28'd1000257) begin
                        y2 <= y2_state;
								x2 <= 7'd70;
								end
								if (counter < 28'd1000384 && counter >= 28'd1000256) begin
								x <= x3;
					 y <= y3;
						    color <= 3'b000;
							 if (counter != 28'd1000256)
							   x3 <= x3 + 7'd1;
							 if (x3 == 7'd155) begin
								y3 <= y3 + 7'd1;
                        x3 <= 7'd140;
							end
                    end
                    if (counter == 28'd1000384) begin
                        x3_state <= x3_state + 7'd1;
                        y3_state <= y3_state + 7'd1;
                    end
                    if (counter == 28'd1000385) begin
                        y3 <= y3_state;
								x3 <= 7'd140;
								end
						if (counter < 28'd1000512 && counter >= 28'd1000384) begin
						x <= x4;
					 y <= y4;
						    color <= 3'b000;
							 if (counter != 28'd1000384)
							   x4 <= x4 + 7'd1;
							 if (x4 == 7'd225) begin
								y4 <= y4 + 7'd1;
                        x4 <= 7'd210;
							end
                    end
                    if (counter == 28'd1000512) begin
                        x4_state <= x4_state + 7'd1;
                        y4_state <= y4_state + 7'd1;
                    end
                    if (counter == 28'd1000513) begin
                        y4 <= y4_state;
								x4 <= 7'd210;
								end
                end
                counter = counter + 28'd1;
            end 
				else begin
                counter <= 28'd0;
            end
        end
    end
    
endmodule
