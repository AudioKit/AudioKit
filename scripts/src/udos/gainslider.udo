/*
gainslider - Logarithmic gain slider

DESCRIPTION
This opcode implements a logarithmic gain curve which is based on the gainslider~ object from Cycling 74 Max / MSP.

SYNTAX
kout  gainslider  kin

PERFORMANCE
kin  --  expected range from 0-152. A range from 0-127 will give you a range of -inf to -0.0 dB. A range of 0-152 will give you a range from -inf to +18.0 dB.

kout  --  scaled output.

CREDITS
David Akbari, 2005
*/

		opcode	gainslider, k, k
kin	xin

kout	=	(0.000145 * exp(kin * 0.06907))

	xout	kout

		endop
 
