module song_amazing_grace(
	input  clock,
	output [7:0]key_code
);

	reg [15:0]tmp;
	wire[15:0]tmpa;
	reg tr;
	reg [15:0]step;
	wire[15:0]step_r;
	reg [15:0]TT;
	reg[5:0]st;
	reg restart;
	reg go_end;

////////Music-processing////////
	always @(negedge restart or posedge clock) begin
	if (!restart) begin
   		step=0;
   		st=0;
   		tr=0;
			restart <= 1'b1;
	end
	else
	if (step<step_r) begin
  		case (st)
  		0: st=st+1;
  		1: begin tr=0; st=st+1;end
  		2: begin tr=1;st=st+1;end
  		3: if(go_end) st=st+1;
  		4: begin st=0;step=step+1;end
  		endcase
	end
	else 
		restart <= 1'b0;
	end

///////////////  pitch  //////////////////
	wire [7:0]key_code1=(
		(TT[3:0]==1)?8'h2b:(//1
		(TT[3:0]==2)?8'h34:(//2
		(TT[3:0]==3)?8'h33:(//3
		(TT[3:0]==4)?8'h3b:(//4
		(TT[3:0]==5)?8'h42:(//5
		(TT[3:0]==6)?8'h4b:(//6
		(TT[3:0]==7)?8'h4c:(//7
		(TT[3:0]==10)?8'h52:(//1
		(TT[3:0]==12)?8'h1c:(//-5
		(TT[3:0]==13)?8'h1b:(//-6
		(TT[3:0]==15)?8'hf0:8'hf0
		))))))))))
	);

///////////////  paddle  ///////////////////
	assign tmpa[15:0]=(
		(TT[7:4]==15)?16'h10:(
		(TT[7:4]==8)? 16'h20:(
		(TT[7:4]==9)? 16'h30:(
		(TT[7:4]==1)? 16'h40:(
		(TT[7:4]==3)? 16'h60:(
		(TT[7:4]==2)? 16'h80:(
		(TT[7:4]==4)? 16'h100:0
		))))))
	);

/////////// note list ///////////
	always @(step) begin
	case (step)
		0:TT=8'h1f;
		1:TT=8'b00011100;
		2:TT=8'b00100001;
		3:TT=8'b10000011;
		4:TT=8'b10000001;
		5:TT=8'b00100011;
		6:TT=8'b00010010;
		7:TT=8'b00100001;
		8:TT=8'b00011101;
		9:TT=8'b00011100;
		10:TT=8'b00011100;
		11:TT=8'b00100001;
		12:TT=8'b10000011;
		13:TT=8'b10000001;
		14:TT=8'b00100011;
		15:TT=8'b00010010;
		16:TT=8'b01000101;
		17:TT=8'b00010011;
		18:TT=8'b00110101;
		19:TT=8'b10000011;
		20:TT=8'b10000101;
		21:TT=8'b10000011;
		22:TT=8'b00100001;
		23:TT=8'b00011100;
		24:TT=8'b00111101;
		25:TT=8'b10000001;
		26:TT=8'b10000001;
		27:TT=8'b10001101;
		28:TT=8'b00101100;
		29:TT=8'b00011100;
		30:TT=8'b00100001;
		31:TT=8'b10000011;
		32:TT=8'b10000001;
		33:TT=8'b00100011;
		34:TT=8'b00010010;
		35:TT=8'b01000001;
		36:TT=8'h1f;
	endcase
	end
	assign step_r=36;///Total note

/////////////KEY release & code-out ////////////////
	always @(negedge tr or posedge clock)begin
		if(!tr) begin 
			tmp=0;
			go_end=0;
			end
		else if (tmp>tmpa)
			go_end=1; 
		else 
			tmp=tmp+1;
	end
	assign key_code=(tmp<(tmpa-1)) ? key_code1 : 8'hf0;

endmodule

