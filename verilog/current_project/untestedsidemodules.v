module counter_4bit(INPUTCLOCK, reset_n, counter,shouldLoad);
	input INPUTCLOCK;
	input reset_n;
	output shouldLoad;
	output reg [2:0] counter;
	
	assign shouldLoad = ~counter[2] & ~counter[1] & ~counter[0];
	
	always @(posedge INPUTCLOCK)
	begin
		if(reset_n == 1'b1)
			counter <= 0;
		else 
			begin
				if (counter == 3'b100)
					counter <= 0;
				else
					counter <= counter + 1'b1;
			end
	end

endmodule

module counter_7bit(INPUTCLOCK, reset_n, counter);
	input INPUTCLOCK;
	input reset_n;
	output reg [6:0] counter;
	
	always @(posedge INPUTCLOCK)
	begin
		if(reset_n == 1'b1)
			counter <= 0;
		else 
			begin
				if (counter == 7'b1111111)
					counter <= 0;
				else
					counter <= counter + 1'b1;
			end
	end

endmodule


module shifterbitNL(OUT, IN, SHIFT, CLK, RESET_N);
	input IN, SHIFT, CLK, RESET_N;
	output OUT;
	
	wire muxconnector, toDflip;
	
	mux2to1 M1(
		.x(OUT),
		.y(IN),
		.s(SHIFT),
		.m(toDflip)
	);
	
	
	flipflop F1(
		.d(toDflip),
		.q(OUT),
		.clk(CLK),
		.reset_n(RESET_N)
	);
		
endmodule

//TAKEN FROM BRIAN-CHIM
module RDF(enable, clkin, clkout);
	input [0:0] enable;
	input clkin;
	output reg [0:0]clkout;
	reg [24:0] count;

	initial begin
		count = 0;
		clkout = 0;
	end

	always @(posedge clkin) begin
		if (enable == 1'b1) begin
			if (count < 6000000)
				count <= count + 1;
			else begin
				count <= 0;
				clkout <= ~clkout;
			end
		end
	end
endmodule

