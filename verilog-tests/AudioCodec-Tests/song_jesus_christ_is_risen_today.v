module song_jesus_christ_is_risen_today(
	input  clock,
	output [7:0]key_code,
	input  k_tr
);

	reg [15:0]tmp;
	wire[15:0]tmpa;
	reg tr;
	reg [15:0]step;
	wire[15:0]step_r;
	reg [15:0]TT;
	reg[5:0]st;
	reg go_end;

////////Music-processing////////
	always @(negedge k_tr or posedge clock) begin
	if (!k_tr) begin
   		step=0;
   		st=0;
   		tr=0;
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
		(TT[3:0]==15)?8'hf0:8'hf0
		))))))))
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
		1:TT=8'b00010001;
		2:TT=8'b00010011;
		3:TT=8'b00010101;
		4:TT=8'b00010001;
		5:TT=8'b00010100;
		6:TT=8'b00010110;
		7:TT=8'b00010110;
		8:TT=8'b00010101;
		9:TT=8'b10000011;
		10:TT=8'b10000100;
		11:TT=8'b10000101;
		12:TT=8'b10000001;
		13:TT=8'b00010100;
		14:TT=8'b10000011;
		15:TT=8'b10000100;
		16:TT=8'b00010011;
		17:TT=8'b00010010;
		18:TT=8'b00100001;
		19:TT=8'b00010100;
		20:TT=8'b00010101;
		21:TT=8'b00010110;
		22:TT=8'b00010101;
		23:TT=8'b00010100;
		24:TT=8'b00010011;
		25:TT=8'b00010011;
		26:TT=8'b00010010;
		27:TT=8'b10000011;
		28:TT=8'b10000100;
		29:TT=8'b10000101;
		30:TT=8'b10000001;
		31:TT=8'b00010100;
		32:TT=8'b10000011;
		33:TT=8'b10000100;
		34:TT=8'b00010011;
		35:TT=8'b00010010;
		36:TT=8'b00100001;
		37:TT=8'b00010111;
		38:TT=8'b00011010;
		39:TT=8'b00010010;
		40:TT=8'b00010101;
		41:TT=8'b00010001;
		42:TT=8'b00010010;
		43:TT=8'b00100011;
		44:TT=8'b10000111;
		45:TT=8'b10001010;
		46:TT=8'b10000010;
		47:TT=8'b10000101;
		48:TT=8'b00011010;
		49:TT=8'b10000111;
		50:TT=8'b10001010;
		51:TT=8'b00010111;
		52:TT=8'b00010110;
		53:TT=8'b00100101;
		54:TT=8'b10000101;
		55:TT=8'b10000110;
		56:TT=8'b10000111;
		57:TT=8'b10000101;
		58:TT=8'b00011010;
		59:TT=8'b00010011;
		60:TT=8'b00010100;
		61:TT=8'b00010110;
		62:TT=8'b00010110;
		63:TT=8'b00010101;
		64:TT=8'b10001010;
		65:TT=8'b10000111;
		66:TT=8'b10001010;
		67:TT=8'b10000101;
		68:TT=8'b10000110;
		69:TT=8'b10000111;
		70:TT=8'b10001010;
		71:TT=8'b10000010;
		72:TT=8'b00011010;
		73:TT=8'b00010111;
		74:TT=8'b00101010;
		75:TT=8'h1f;
	endcase
	end
	assign step_r=75;///Total note

/////////////KEY release & code-out ////////////////
	always @(negedge tr or posedge clock)begin
		if(!tr) begin tmp=0;go_end=0 ;end
		else if (tmp>tmpa)go_end=1; 
		else tmp=tmp+1;
	end
	assign key_code=(tmp<(tmpa-1))?key_code1:8'hf0;

endmodule

