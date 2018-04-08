// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions:	DE2_115_Default
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author              :| Mod. Date :| Changes Made:
//   V1.1 :| HdHuang             :| 05/12/10  :| Initial Revision
//   V2.0 :| Eko       				:| 05/23/12  :| version 11.1
// ============================================================================
						 												

module audio_module(CLOCK_50, /*KEY,*/ AUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, AUD_XCK, I2C_SCLK, I2C_SDAT, TD_CLK27,TD_RESET_N, resetter);


//////////// CLOCK //////////
input		          		CLOCK_50;

//////////// KEY //////////
//input		     [3:0]		KEY;

//////////// Audio //////////
input		          		AUD_ADCDAT;
inout		          		AUD_ADCLRCK;
inout		          		AUD_BCLK;
output		        		AUD_DACDAT;
inout		          		AUD_DACLRCK;
output		        		AUD_XCK;


//////////// I2C for Audio and Tv-Decode //////////
output		        		I2C_SCLK;
inout		          		I2C_SDAT;

//////////// TV Decoder 1 //////////
input		          		TD_CLK27;
output		        		TD_RESET_N;
input resetter;



wire I2C_END;
wire AUD_CTRL_CLK;
reg	[31:0] VGA_CLKo;
wire demo_clock ; 
wire [7:0] song_code1;


//=============================================================================
// Structural coding
//=============================================================================
	
	
//  TV DECODER ENABLE 
	
assign TD_RESET_N =1'b1;


//  I2C

	I2C_AV_Config 	u7	(.iCLK(CLOCK_50),.iRST_N( 1'b1 ),.o_I2C_END( I2C_END ),.I2C_SCLK( I2C_SCLK ),.I2C_SDAT(I2C_SDAT));


//	AUDIO SOUND

	assign	AUD_ADCLRCK	=	AUD_DACLRCK;
	assign	AUD_XCK	   =	AUD_CTRL_CLK;			

//  AUDIO PLL

	VGA_Audio_PLL 	u1(.areset( ~I2C_END ),.inclk0( TD_CLK27 ),.c1( AUD_CTRL_CLK ));

////////////Sound Select/////////////	

	wire [15:0]	sound1;
	wire [15:0]	sound2;
	wire [15:0]	sound3;
	wire [15:0]	sound4;
	wire 			sound_off1;
	wire 			sound_off2;
	wire 			sound_off3;
	wire 			sound_off4;
	
	
	assign demo_clock      = VGA_CLKo[18]; 
	always @( posedge CLOCK_50 )
		begin
			VGA_CLKo <= VGA_CLKo + 1;
		end
		
	song_amazing_grace dd1(.clock( demo_clock ),.key_code( song_code1 ),.resetter(resetter));	//,.k_tr( KEY[1] & KEY[0] )

	wire [7:0]sound_code1 = song_code1; //SW[9]=0 is DEMO SOUND,otherwise key
	wire [7:0]sound_code2 = 0;
	wire [7:0]sound_code3 = 0;
	wire [7:0]sound_code4 = 0;


	staff st1(
			 // Key code-in //
		
			 .scan_code1		( sound_code1 ),
			 .scan_code2		( sound_code2 ),
			 .scan_code3      ( sound_code3 ), // OFF
			 .scan_code4		( sound_code4 ), // OFF
		
			 //Sound Output to Audio Generater//
		
			 .sound1				( sound1 ),
			 .sound2				( sound2 ),
			 .sound3				( sound3 ), // OFF
			 .sound4				( sound4 ), // OFF
		
			 .sound_off1		( sound_off1 ),
			 .sound_off2		( sound_off2 ),
			 .sound_off3		( sound_off3 ), //OFF
			 .sound_off4		( sound_off4 )	 //OFF	
	        );
					
// 2CH Audio Sound output -- Audio Generater //
	adio_codec ad1	(	
					// AUDIO CODEC //
					.oAUD_BCK 	( AUD_BCLK ),
					.oAUD_DATA	( AUD_DACDAT ),
					.oAUD_LRCK	( AUD_DACLRCK ),																
					.iCLK_18_4	( AUD_CTRL_CLK ),
			
					// KEY //
		
					.iRST_N	  	( 1'b1 ),							
					.iSrc_Select( 2'b00 ),

					// Sound Control //

					.key1_on		( 1'b1 ),//CH1 ON / OFF		
					.key2_on		( 1'b0 ),//CH2 ON / OFF
					.key3_on		( 1'b0 ),			    	// OFF
					.key4_on		( 1'b0 ), 					// OFF							
					.sound1		( sound1 ),					// CH1 Freq
					.sound2		( sound2 ),					// CH2 Freq
					.sound3		( sound3 ),					// OFF,CH3 Freq
					.sound4		( sound4 ),					// OFF,CH4 Freq							
					.instru		( 1'b0 )  					// INSTUMENT SELECTION - 1 is OFF?, 0 is BRASS
					);

endmodule
