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

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule

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

