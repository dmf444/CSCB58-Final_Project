module hexcounter(
 input clock, reset,
 input in0, in1, in2, in3, 
 output a, b, c, d, e, f, g, dp,
 output [3:0] an 
 );
 
localparam N = 18;
 
reg [N-1:0]count;
 
always @ (posedge clock or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end
 
reg [6:0]sseg; //the 7 bit register to hold the data to output
reg [3:0]an_temp; //register for the 4 bit enable
 
always @ (*)
 begin
  case(count[N-1:N-2])
    
   2'b00 : 
    begin
     sseg = in0;
     an_temp = 4'b1110;
    end
    
   2'b01: 
    begin
     sseg = in1;
     an_temp = 4'b1101;
    end
    
   2'b10: 
    begin
     sseg = in2;
     an_temp = 4'b1011;
    end
     
   2'b11: 
    begin
     sseg = in3;
     an_temp = 4'b0111;
    end
  endcase
 end
assign an = an_temp;
 
 
reg [6:0] sseg_temp;
 
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b1000000;
   4'd1 : sseg_temp = 7'b1111001;
   4'd2 : sseg_temp = 7'b0100100;
   4'd3 : sseg_temp = 7'b0110000;
   4'd4 : sseg_temp = 7'b0011001;
   4'd5 : sseg_temp = 7'b0010010;
   4'd6 : sseg_temp = 7'b0000010;
   4'd7 : sseg_temp = 7'b1111000;
   4'd8 : sseg_temp = 7'b0000000;
   4'd9 : sseg_temp = 7'b0010000;
   default : sseg_temp = 7'b0111111;
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp;
 
assign dp = 1'b1;
 
 
endmodule