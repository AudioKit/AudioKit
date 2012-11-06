/*
p5glove - Unit generator for P5 data glove

DESCRIPTION
Based on the Max Mathews Radio Baton opcodes from CsoundAV, this Csound5 opcode implements an OSC receiver intended for use with the P5 dataglove. 

General information on the p5 dataglove can be found here: http://www.vrealities.com/P5.html

SYNTAX
kA, kB, kC, kf1, kf2, kf3, kf4, kf5, kX, kY, kZ    p5glove    ihandle

INITIALIZATION
ihandle  --  Handle reference to a port to listen to from previous instance of the OSCinit opcode.

PERFORMANCE
kA  --  glove data from Button A (0 or 1)
kB  --  glove data from Button B (0 or 1)
kC  --  glove data from Button C (0 or 1)

kf1  --  THUMB bend data (in range 0-63)
kf2  --  INDEX finger bend data (in range 0-63)
kf3  --  MIDDLE finger bend data (in range 0-63)
kf4  --  RING finger bend data (in range 0-63)
kf5  --  PINKY finger bend data (in range 0-63)

kX  --  proximity of glove to sensor stand X-AXIS
kY  --  proximity of glove to sensor stand Y-AXIS
kZ  --  proximity of glove to sensor stand Z-AXIS

NOTE : All values are returned as integers by default. It is recommended to scale the data in your .orc

CREDITS
David Akbari - 2005
*/

opcode   p5glove, kkkkkkkkkkk, i	; p5 glove UDO

kf1 init 0         
kf2 init 0       
kf3 init 0         
kf4 init 0       
kf5 init 0         
kf6 init 0       
kf7 init 0         
kf8 init 0       
kf9 init 0         
kf10 init 0       
kf11 init 0         

ihandle  xin

	kk  OSClisten ihandle, "/p5glove_data", "fffffffffff", kf1, kf2, kf3, kf4, kf5, kf6, kf7, kf8, kf9, kf10, kf11

if kk =0 goto ex

	xout	kf1,kf2,kf3,kf4,kf5,kf6,kf7,kf8,kf9,kf10,kf11

	ex:
		endop
 
