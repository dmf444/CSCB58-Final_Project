// Part 2 skeleton

module vga_display
  (
    CLOCK_50,                       //  On Board 50 MHz
    KEY,
    VGA_CLK,                        //  VGA Clock
    VGA_HS,                         //  VGA H_SYNC
    VGA_VS,                         //  VGA V_SYNC
    VGA_BLANK_N,                    //  VGA BLANK
    VGA_SYNC_N,                     //  VGA SYNC
    VGA_R,                          //  VGA Red[9:0]
    VGA_G,                          //  VGA Green[9:0]
    VGA_B,                //  VGA Blue[9:0]
    track1_in,
    track2_in,
    track3_in,
    track4_in,
    h0,
    h1,
    h2,
    h3
  );

  input           CLOCK_50;               //  50 MHz
  input   [3:0]   KEY;
  input track1_in, track2_in, track3_in, track4_in;

  output          VGA_CLK;                //  VGA Clock
  output          VGA_HS;                 //  VGA H_SYNC
  output          VGA_VS;                 //  VGA V_SYNC
  output          VGA_BLANK_N;            //  VGA BLANK
  output          VGA_SYNC_N;             //  VGA SYNC
  output  [9:0]   VGA_R;                  //  VGA Red[9:0]
  output  [9:0]   VGA_G;                  //  VGA Green[9:0]
  output  [9:0]   VGA_B;                  //  VGA Blue[9:0]
  output  [6:0]   h0, h1, h2, h3;

  wire            resetn;
  wire    [2:0]   colour;
  wire    [7:0]   x;
  wire    [7:0]   y;

  assign resetn = 1'b1;

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
  defparam VGA.BACKGROUND_IMAGE = "verilog/background.mif";

  // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
  // for the VGA controller, in addition to any other functionality your design may require.

  // Instansiate datapath
  datapath d0(
    .clk(CLOCK_50),
    .resetn(resetn),
    .track1(track1_in),
    .track2(track2_in),
    .track3(track3_in),
    .track4(track4_in),
    .key1(KEY[3]),
    .key2(KEY[2]),
    .key3(KEY[1]),
    .key4(KEY[0]),
    .x(x),
    .y(y),
    .color(colour),
    .h0(h0),
    .h1(h1),
    .h2(h2),
    .h3(h3)
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
  output [6:0] h0,
  output [6:0] h1,
  output [6:0] h2,
  output [6:0] h3,
  output reg [7:0] x,
  output reg [7:0] y,
  output reg [2:0] color
);

  reg [7:0]  x1 = 8'd15;
  reg [7:0]  y1 = 8'd0;
  reg [7:0]  x2 = 8'd53;
  reg [7:0]  y2 = 8'd0;
  reg [7:0]  x3 = 8'd91;
  reg [7:0]  y3 = 8'd0;
  reg [7:0]  x4 = 8'd129;
  reg [7:0]  y4 = 8'd0;

  reg [7:0]  x_state  = 8'd0;
  reg [7:0]  y_state  = 8'd0;
  reg [7:0]  x2_state = 8'd0;
  reg [7:0]  y2_state = 8'd0;
  reg [7:0]  x3_state = 8'd0;
  reg [7:0]  y3_state = 8'd0;
  reg [7:0]  x4_state = 8'd0;
  reg [7:0]  y4_state = 8'd0;

  reg [27:0] counter = 28'd0;

  reg track1_state = 0;
  reg track2_state = 0;
  reg track3_state = 0;
  reg track4_state = 0;

  reg [7:0] y_up   = 8'd92;
  reg [7:0] y_down = 8'd81;

  reg [3:0] score1 = 4'd0;
  reg [3:0] score2 = 4'd0;
  reg [3:0] score3 = 4'd0;
  reg [3:0] score4 = 4'd0;

  hexdisplay hx0(.hex_digit(score1), .OUT(h0[6:0]));
  hexdisplay hx1(.hex_digit(score2), .OUT(h1[6:0]));
  hexdisplay hx2(.hex_digit(score3), .OUT(h2[6:0]));
  hexdisplay hx3(.hex_digit(score4), .OUT(h3[6:0]));

  always@(posedge clk, negedge resetn) begin
    if(!resetn) begin
      x_state <= 8'd0;
      y_state <= 8'd0;
      counter <= 28'd0;
      score1 <= 0;
      score2 <= 0;
      score3 <= 0;
      score4 <= 0;
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
          y_state <= 8'd0;
        if (!track2_state)
          y2_state <= 8'd0;
        if (!track3_state)
          y3_state <= 8'd0;
        if (!track4_state)
          y4_state <= 8'd0;

        // Registering pressed notes and incrementing score for player
        if (!key1 && y_state <= y_up && y_state >= y_down) begin
          score1 <= score1 + 1;
          track1_state <= 0;
          y_state <= 8'd0;
        end
        else begin
          if (!key1 && (y_state > y_up || y_state < y_down) && y_state != 0) begin
            score1 <= 0;
            score2 <= 0;
            score3 <= 0;
            score4 <= 0;
          end
        end
        if (!key2 && y2_state <= y_up && y2_state >= y_down) begin
          score1 <= score1 + 1;
          track2_state <= 0;
          y2_state <= 8'd0;
        end
        else begin
          if (!key2 && (y2_state > y_up || y2_state < y_down) && y2_state != 0) begin
            score1 <= 0;
            score2 <= 0;
            score3 <= 0;
            score4 <= 0;
          end
        end
        if (!key3 && y3_state <= y_up && y3_state >= y_down) begin
          score1 <= score1 + 1;
          track3_state <= 0;
          y3_state <= 8'd0;
        end
        else begin
          if (!key3 && (y3_state > y_up || y3_state < y_down) && y3_state != 0) begin
            score1 <= 0;
            score2 <= 0;
            score3 <= 0;
            score4 <= 0;
          end
        end
        if (!key4 && y4_state <= y_up && y4_state >= y_down) begin
          score1 <= score1 + 1;
          track4_state <= 0;
          y4_state <= 8'd0;
        end
        else begin
          if (!key4 && (y4_state > y_up || y4_state < y_down) && y4_state != 0) begin
            score1 <= 0;
            score2 <= 0;
            score3 <= 0;
            score4 <= 0;
          end
        end

        // Register to display score on hex displays
        if (score1 >= 4'd10) begin
          score1 <= 4'd0;
          score2 <= score2 + 1;
        end
        if (score2 >= 4'd10) begin
          score2 <= 4'd0;
          score3 <= score3 + 1;
        end
        if (score3 >= 4'd10) begin
          score3 <= 4'd0;
          score4 <= score4 + 1;
        end

        // Reseting tracks when they hit the bottom of the screen
        if (y1 == 127)
          track1_state <= 0;
        if (y2 == 127)
          track2_state <= 0;
        if (y3 == 127)
          track3_state <= 0;
        if (y4 == 127)
          track4_state <= 0;

        // DRAW
        // First Track (Drawing)
        if (counter < 28'd128) begin
          x <= x1;
          y <= y1;
          if (y_state == 0)
            color <= 3'b000;
          else
            color <= 3'b100;
          if (counter != 28'd0) 
            x1 <= x1 + 7'd1;
          if (x1 == 8'd30) begin
            y1 <= y1 + 8'd1;
            x1 <= 8'd15;
          end
        end
        // First Track (Resetin the states)
        if (counter == 28'd129) begin
          y1 <= y_state;
          x1 <= 8'd15;
        end

        // Second Track (Drawing)
        if (counter < 28'd256 && counter >= 28'd129) begin
          x <= x2;
          y <= y2;
          if (y2_state == 0)
            color <= 3'b000;
          else
            color <= 3'b110;
          if (counter != 28'd128) 
            x2 <= x2 + 8'd1;
          if (x2 == 8'd68) begin
            y2 <= y2 + 8'd1;
            x2 <= 8'd53;
          end
        end
        // Second Track (Resetin the states)
        if (counter == 28'd256) begin
          y2 <= y2_state;
          x2 <= 8'd53;
        end

        // Third Track (Drawing)
        if (counter < 28'd384 && counter >= 28'd256) begin
          x <= x3;
          y <= y3;
          if (y3_state == 0)
            color <= 3'b000;
          else
            color <= 3'b111;
          if (counter != 28'd256) 
            x3 <= x3 + 8'd1;
          if (x3 == 8'd106) begin
            y3 <= y3 + 8'd1;
            x3 <= 8'd91;
          end
        end
        // Third Track (Reseting the states)
        if (counter == 28'd384) begin
          y3 <= y3_state;
          x3 <= 8'd91;
        end

        // Fourth Track (Drawing)
        if (counter < 28'd512 && counter >= 28'd384) begin
          x <= x4;
          y <= y4;
          if (y4_state == 0)
            color <= 3'b000;
          else
            color <= 3'b011;
          if (counter != 28'd384) 
            x4 <= x4 + 8'd1;
          if (x4 == 8'd144) begin
            y4 <= y4 + 8'd1;
            x4 <= 8'd129;
          end
        end
        // Fourth Track (Resetin the states)
        if (counter == 28'd512) begin
          y4 <= y4_state;
          x4 <= 8'd129;
        end

        // DELETE
        if (counter >= 28'd1000000) begin
          // First Track (Deleting)
          if (counter < 28'd1000128) begin
            x <= x1;
            y <= y1;
            if (y1 == 80 || y1 == 100)
              color <= 3'b110;
            else
              color <= 3'b000;
            if (counter != 28'd1000000)
              x1 <= x1 + 8'd1;
            if (x1 == 8'd30) begin
              y1 <= y1 + 8'd1;
              x1 <= 8'd15;
            end
          end
          // First Track (Changing the states)
          if (counter == 28'd1000128) begin
            x_state <= x_state + 8'd1;
            y_state <= y_state + 8'd1;
          end
          // First Track (Resetin the states)
          if (counter == 28'd1000129) begin
            y1 <= y_state;
            x1 <= 8'd15;
          end

          // Second Track (Deleting)
          if (counter < 28'd1000256 && counter >= 28'd1000128) begin
            x <= x2;
            y <= y2;
            if (y2 == 80 || y2 == 100)
              color <= 3'b110;
            else
              color <= 3'b000;
            if (counter != 28'd1000128)
              x2 <= x2 + 8'd1;
            if (x2 == 8'd68) begin
              y2 <= y2 + 8'd1;
              x2 <= 8'd53;
            end
          end
          // Second Track (Changing the states)
          if (counter == 28'd1000256) begin
            x2_state <= x2_state + 8'd1;
            y2_state <= y2_state + 8'd1;
          end
          // Second Track (Resetin the states)
          if (counter == 28'd1000257) begin
            y2 <= y2_state;
            x2 <= 8'd53;
          end

          // Third Track (Deleting)
          if (counter < 28'd1000384 && counter >= 28'd1000256) begin
            x <= x3;
            y <= y3;
            if (y3 == 80 || y3 == 100)
              color <= 3'b110;
            else
              color <= 3'b000;
            if (counter != 28'd1000256)
              x3 <= x3 + 8'd1;
            if (x3 == 8'd106) begin
              y3 <= y3 + 8'd1;
              x3 <= 8'd91;
            end
          end
          // Third Track (Changing the states)
          if (counter == 28'd1000384) begin
            x3_state <= x3_state + 8'd1;
            y3_state <= y3_state + 8'd1;
          end
          // Third Track (Resetin the states)
          if (counter == 28'd1000385) begin
            y3 <= y3_state;
            x3 <= 8'd91;
          end

          // Fourth Track (Deleting)
          if (counter < 28'd1000512 && counter >= 28'd1000384) begin
            x <= x4;
            y <= y4;
            if (y4 == 80 || y4 == 100)
              color <= 3'b110;
            else
              color <= 3'b000;
            if (counter != 28'd1000384)
              x4 <= x4 + 8'd1;
            if (x4 == 8'd144) begin
              y4 <= y4 + 8'd1;
              x4 <= 8'd129;
            end
          end
          // Fourth Track (Changing the states)
          if (counter == 28'd1000512) begin
            x4_state <= x4_state + 8'd1;
            y4_state <= y4_state + 8'd1;
          end
          // Fourth Track (Resetin the states)
          if (counter == 28'd1000513) begin
            y4 <= y4_state;
            x4 <= 8'd129;
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
