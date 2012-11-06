/*
stereoMS - Converts Stereo to MS and MS to Stereo.

DESCRIPTION
Converts Stereo to Middle/Side and Middle/Side to Stereo.

SYNTAX
aout1, aout2 stereoMS ain1, ain2

INITIALIZATION
ain1 -- left or middle audio channel
ain2 -- right or side audio channel

PERFORMANCE
Converts Stereo to Middle/Side and Middle/Side to Stereo.  The math is the same so this opcode can be used in both directions.

CREDITS
Joseph Anderson and ma++, jan 2005
*/

opcode stereoMS, aa, aa

	ain1, ain2	xin

	ifac	=	.5 * sqrt(2)
	aout1	=	ifac * (ain1 + ain2)
	aout2	=	ifac * (ain1 - ain2)

	xout aout1, aout2

endop
 
