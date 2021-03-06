//A standard bit shifter.
module shifterbit(OUT, IN, LOAD, SHIFT, LOAD_N, CLK, RESET_N);
	input IN, LOAD, SHIFT, LOAD_N, CLK, RESET_N;
	output OUT;
	
	wire muxconnector, toDflip;
	
	mux2to1 M1(
		.x(OUT),
		.y(IN),
		.s(SHIFT),
		.m(muxconnector)
	);
	
	mux2to1 M2(
		.x(LOAD),
		.y(muxconnector),
		.s(LOAD_N),
		.m(toDflip)
	);
	
	flipflop F0(
		.d(toDflip),
		.q(OUT),
		.clk(CLK),
		.reset_n(RESET_N)
	);
		
endmodule

//A standard 2-to-1 mux
module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule

//A standard flip-flop
module flipflop(d, reset_n, clk, q);
	input d, reset_n, clk;
	output q;
	reg q;
	
	always @(posedge clk)
	begin
		if(reset_n == 1'b0)
			q <= 0;
		else 
			q <= d;
	end
endmodule


//the hex module, to display score on the board
module hexdisplay(hex_digit, OUT);
    input [3:0] hex_digit;
	 output reg [7:0] OUT;
	 
	 always @(*)
	 begin
		case(hex_digit[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			
			default: OUT = 7'b0111111;
		endcase

	end
endmodule
