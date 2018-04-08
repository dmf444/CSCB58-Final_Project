module counter_4bit(INPUTCLOCK, reset_n, counter,shouldLoad);
	input INPUTCLOCK;
	input reset_n;
	output shouldLoad;
	output reg [1:0] counter;
	
	nand(shouldLoad, counter[1], counter[0]);
	
	always @(posedge INPUTCLOCK)
	begin
		if(reset_n == 1'b1)
			counter <= 0;
		else 
			counter <= counter + 1'b1;
	end

endmodule
