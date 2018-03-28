// Part 2 skeleton

module gameTest
    (
        CLOCK_50,                       //  On Board 50 MHz
        KEY,
        SW,
        VGA_CLK,                        //  VGA Clock
        VGA_HS,                         //  VGA H_SYNC
        VGA_VS,                         //  VGA V_SYNC
        VGA_BLANK_N,                        //  VGA BLANK
        VGA_SYNC_N,                     //  VGA SYNC
        VGA_R,                          //  VGA Red[9:0]
        VGA_G,                          //  VGA Green[9:0]
        VGA_B                           //  VGA Blue[9:0]
    );

    input           CLOCK_50;               //  50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;

    output          VGA_CLK;                //  VGA Clock
    output          VGA_HS;                 //  VGA H_SYNC
    output          VGA_VS;                 //  VGA V_SYNC
    output          VGA_BLANK_N;                //  VGA BLANK
    output          VGA_SYNC_N;             //  VGA SYNC
    output  [9:0]   VGA_R;                  //  VGA Red[9:0]
    output  [9:0]   VGA_G;                  //  VGA Green[9:0]
    output  [9:0]   VGA_B;                  //  VGA Blue[9:0]
    
    wire    [6:0]   x2;
    wire            resetn;
    wire    [2:0]   colour;
    wire    [6:0]   x;
    wire    [6:0]   y;

    assign resetn = SW[9];
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
        defparam VGA.BACKGROUND_IMAGE = "tron.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
    datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
	.track1(SW[0]),
	.track2(SW[1]),
	.track3(SW[2]),
	.track4(SW[3]),
	.key1(KEY[3]),
	.key2(KEY[2]),
	.key3(KEY[1]),
	.key4(KEY[0]),
        .x(x2),
        .y(y),
        .color(colour)
    );
    
endmodule


module datapath(
    input clk,
    input resetn,
    input track1,
    input track2,
    input track3,
    input track4,
    input key1,
    input key2,
    input key3,
    input key4,
    output reg [6:0] x,
    output reg [6:0] y,
    output reg [2:0] color
    );
 
    reg [6:0]  x1 = 7'd0;
    reg [6:0]  y1 = 7'd0;
    reg [6:0]  x2 = 7'd20;
    reg [6:0]  y2 = 7'd0;
    reg [6:0]  x3 = 7'd40;
    reg [6:0]  y3 = 7'd0;
    reg [6:0]  x4 = 7'd60;
    reg [6:0]  y4 = 7'd0;

    reg [6:0]  x_state  = 7'd0;
    reg [6:0]  y_state  = 7'd0;
    reg [6:0]  x2_state = 7'd0;
    reg [6:0]  y2_state = 7'd0;
    reg [6:0]  x3_state = 7'd0;
    reg [6:0]  y3_state = 7'd0;
    reg [6:0]  x4_state = 7'd0;
    reg [6:0]  y4_state = 7'd0;

    reg [27:0] counter = 28'd0;

    reg track1_state = 0;
    reg track2_state = 0;
    reg track3_state = 0;
    reg track4_state = 0;

    reg [6:0] y_up   = 7'd80;
    reg [6:0] y_down = 7'd105;

    reg [6:0] score = 7'd0;
    
    always@(posedge clk) begin
        if(resetn) begin
            x_state <= 7'd0;
            y_state <= 7'd0;
            counter <= 28'd0;
            score <= 7'd0;
        end
        else begin
            // Game Counter
            if (counter < 28'd1000514) begin
                // Checking for pulse for each track
                if (track1)
                    track1_state <= 1;
                if (track2)
                    track2_state <= 1;
                if (track3)
                    track3_state <= 1;
                if (track4)
                    track4_state <= 1;

                // Stopping tracks when pulse is not sent
		if (!track1_state)
		    y_state <= 7'd0;
		if (!track2_state)
		    y2_state <= 7'd0;
		if (!track3_state)
		    y3_state <= 7'd0;
		if (!track4_state)
		    y4_state <= 7'd0;

                // Pressing Notes
		if (!key1 && y1 <= y_up && y1 >= y_down) begin
                    score <= score + 1;
                    track1_state <= 0;
                end
		if (!key2 && y2 <= y_up && y2 >= y_down) begin
                    score <= score + 1;
                    track2_state <= 0;
                end
		if (!key3 && y3 <= y_up && y3 >= y_down) begin
                    score <= score + 1;
                    track3_state <= 0;
                end
		if (!key4 && y4 <= y_up && y4 >= y_down) begin
                    score <= score + 1;
                    track4_state <= 0;
                end

                // Reseting tracks when they hit the bottom of the screen
                if (y1 == 104)
                    track1_state <= 0;
                if (y2 == 104)
                    track2_state <= 0;
                if (y3 == 104)
                    track3_state <= 0;
                if (y4 == 104)
                    track4_state <= 0;

                // DRAW
                // First Track (Drawing)
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
                // First Track (Resetin the states)
                if (counter == 28'd129) begin
                    y1 <= y_state;
                    x1 <= 7'd0;
                end

                // Second Track (Drawing)
                if (counter < 28'd256 && counter >= 28'd129) begin
                    x <= x2;
                    y <= y2;
                    color <= 3'b110;
                    if (counter != 28'd128) 
                        x2 <= x2 + 7'd1;
                    if (x2 == 7'd35) begin
                        y2 <= y2 + 7'd1;
                        x2 <= 7'd20;
                    end
                end
                // Second Track (Resetin the states)
                if (counter == 28'd256) begin
                    y2 <= y2_state;
                    x2 <= 7'd20;
                end

                // Third Track (Drawing)
                if (counter < 28'd384 && counter >= 28'd256) begin
                    x <= x3;
                    y <= y3;
                    color <= 3'b111;
                    if (counter != 28'd256) 
                        x3 <= x3 + 7'd1;
                    if (x3 == 7'd55) begin
                        y3 <= y3 + 7'd1;
                        x3 <= 7'd40;
                    end
                end
                // Third Track (Reseting the states)
                if (counter == 28'd384) begin
                    y3 <= y3_state;
                    x3 <= 7'd40;
                end

                // Fourth Track (Drawing)
                if (counter < 28'd512 && counter >= 28'd384) begin
                    x <= x4;
                    y <= y4;
                    color <= 3'b011;
                    if (counter != 28'd384) 
                        x4 <= x4 + 7'd1;
                    if (x4 == 7'd75) begin
                        y4 <= y4 + 7'd1;
                        x4 <= 7'd60;
                    end
                end
                // Fourth Track (Resetin the states)
                if (counter == 28'd512) begin
                    y4 <= y4_state;
                    x4 <= 7'd60;
                end

                // DELETE
                if (counter >= 28'd1000000) begin
                    // First Track (Deleting)
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
                    // First Track (Changing the states)
                    if (counter == 28'd1000128) begin
                        x_state <= x_state + 7'd1;
                        y_state <= y_state + 7'd1;
                    end
                    // First Track (Resetin the states)
                    if (counter == 28'd1000129) begin
                        y1 <= y_state;
                        x1 <= 7'd0;
                    end

                    // Second Track (Deleting)
                    if (counter < 28'd1000256 && counter >= 28'd1000128) begin
                        x <= x2;
                        y <= y2;
                        color <= 3'b000;
                        if (counter != 28'd1000128)
                            x2 <= x2 + 7'd1;
                        if (x2 == 7'd35) begin
                            y2 <= y2 + 7'd1;
                            x2 <= 7'd20;
                        end
                    end
                    // Second Track (Changing the states)
                    if (counter == 28'd1000256) begin
                        x2_state <= x2_state + 7'd1;
                        y2_state <= y2_state + 7'd1;
                    end
                    // Second Track (Resetin the states)
                    if (counter == 28'd1000257) begin
                        y2 <= y2_state;
                        x2 <= 7'd20;
                    end

                    // Third Track (Deleting)
                    if (counter < 28'd1000384 && counter >= 28'd1000256) begin
                        x <= x3;
                        y <= y3;
                        color <= 3'b000;
                        if (counter != 28'd1000256)
                            x3 <= x3 + 7'd1;
                        if (x3 == 7'd55) begin
                            y3 <= y3 + 7'd1;
                            x3 <= 7'd40;
                        end
                    end
                    // Third Track (Changing the states)
                    if (counter == 28'd1000384) begin
                        x3_state <= x3_state + 7'd1;
                        y3_state <= y3_state + 7'd1;
                    end
                    // Third Track (Resetin the states)
                    if (counter == 28'd1000385) begin
                        y3 <= y3_state;
                        x3 <= 7'd40;
                    end

                    // Fourth Track (Deleting)
                    if (counter < 28'd1000512 && counter >= 28'd1000384) begin
                        x <= x4;
                        y <= y4;
                        color <= 3'b000;
                        if (counter != 28'd1000384)
                            x4 <= x4 + 7'd1;
                        if (x4 == 7'd75) begin
                            y4 <= y4 + 7'd1;
                            x4 <= 7'd60;
                        end
                    end
                    // Fourth Track (Changing the states)
                    if (counter == 28'd1000512) begin
                        x4_state <= x4_state + 7'd1;
                        y4_state <= y4_state + 7'd1;
                    end
                    // Fourth Track (Resetin the states)
                    if (counter == 28'd1000513) begin
                        y4 <= y4_state;
                        x4 <= 7'd60;
                    end
                end
                // Counter going up
                counter = counter + 28'd1;
            end
            // Reset the counter
            else begin
                counter <= 28'd0;
            end
        end
    end
    
endmodule
