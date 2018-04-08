# CSCB58-Final_Project
Our project for the DE2-115 board. What did we make? Guitar Hero 115!

##### Here's some useful information:

Video Link: [YouTube](http://github.com)


# What our Project does

This project emulates a simple version of Guitar Hero. RAM tracks load preset values from .MIF files, and output them into shifting bits, of a length of 8. Once a value of 1 is detected in the middle of the shifting bits, a signal is sent to the VGA code, telling it to draw a box on a track and animate. From that point on, the VGA code track the location of the box on the screen and if it falls within a certain area, adds a point to the scoreboard. Hitting the box outside the area will stop it from falling, clear it off the board and reset your score. While this is all happening, the board is also playing one specific song, either Amazing Grace or a Hymnal borrowed from CBW III (Song choice is however, not selectable on the board and only changeable at compilation time). We also added a high score feature (max 99 points) and a reset switch.  

| Input         | USE           |
| ------------- |:-------------:|
| KEY[0]        | Right-most track controller      |
| KEY[1]        | Center-right track controller    |
| KEY[2]        | Center-left track controller     |
| KEY[3]        | Left-most track controller       |
| SW[12]        | Reset the game                   |
| HEX0          | Ones column of the current score |
| HEX1          | Tens column of the current score |
| HEX2          | Ones column of the high score    |
| HEX3          | Tens column of the high score    |


### Repo Outline
##### For anyone else in B58 who needs quick info
* finalProjectMark1

   This contains the final project code that was brought into the final 3 hour practical section. Mostly a merge of the audio tests with the MergedVGA/SingleTrack tests.
* finalProjectMark2-Submitted

   This is the complete project, as demonstrated in the video and showcased to the TA's. You can see the small features we added during the final lab (high-scores, proper game resets) and explore our final project code. Root file is GuitarHero115_Modularized.
* verilog-tests

   This mostly contains our work leading up to the final week. Sub-folders a better labeled below.
   * AudioCodec-Tests
   
      This is the .v files for the audio codex to properly function. Inside this folder you should find all the .v files needed to play a song (Amazing Grace or Jesus Christ is risen today) and an indepth write-up of how it works.
   * Merged-VGAandSingle-Updated
   
      After merging the VGA and Single track code, we spent 6 hours between lab and Makerspace to clean it up and add new features. This is the result of 6 hour of verilog updates. Root file is GuitarHero115_Modularized.
   * Merged-VGAandSingle
   
      This is the VGA display code and the RAM-Shift tracks merged together, compiling, but untested on a DE2-115 board. Root file is GuitarHero115_Modularized.
   * Test1-BasicRamShift
   
      Basically, this test was to ensure that a .mif file could be the source of data for a RAM block
   * Test2-SimpleTrack
   
      Take the RAM from TEST1 and see if it can be loaded into a shifter, and moved accordingly.
   * Test3-LEDHero
   
      This is one RAM track loading properly into it's shifters, then shifting down the line. Using KEY[3], you can actually hit the button and accumulate a score. It's rather difficult, and takes practice (and the "good" DE2-115 board!).
   * Test4-4RAMShifts
   
      Removed the LED function from Test3, and added 3 more RAM blocks, 3 more 8bit shifter and a more complex add score system. Rather close in comparison to the last test, but now can function as a 4-track guitar hero.
   * VGA-Tests
   
      All the code for the VGA display to function. gameTest.v is the root file.
      
## Attributions:

From [brian-chim/b58_snake](https://github.com/brian-chim/b58_snake/blob/master/FinalFinal/helpers2.v#L28) we took module *rate_divider_fast()*, as seen in untestedsidemodules.v as module *RDF()*

From [altera - Demo CD](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502&PartNo=4) we took all of the code for the Music Synthesiser. Most of it was modified to remove some extra feature and change the default song, but altera's fingerprint is still clearly visible on the code. This is all the files included in the audio_module folder.
 
