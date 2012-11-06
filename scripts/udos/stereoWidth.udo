/*
stereoWidth - Changes the image width of a stereo signal

DESCRIPTION
Changes the width of a stereo image, equivalent to adjusting the side component of an M/S signal. Negative values from 0 to -45 will narrow the width of the image. Positive values will in principle increase the width of an image, with the risk of "phasey" components.

SYNTAX
al, ar stereoWidth ainl, ainr, kwidth

INITIALIZATION
ainl, ainr -- input audio signal 

kwidth -- the width of rotation in degrees, usually in the range of -45 to +45

CREDITS
Joseph Anderson and ma++, jan 2011
*/

opcode stereoWidth, aa, aak

	ainl, ainr, ktheta xin

	; constants
	ipi		=	3.141592653589793
	iradfac		=	ipi/180

	;compute coeffs
	ktheta		=	iradfac*ktheta
	kstheta		=	sin(ktheta)
	kctheta		=	cos(ktheta)
	
	;Do Width
	aoutl		=	kctheta*ainl - kstheta*ainr
	aoutr		=	-kstheta*ainl + kctheta*ainr

	xout aoutl, aoutr

endop	
 
