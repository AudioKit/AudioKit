/*
stereoRotate - Stereo 'panning' using the middle-side technique.

DESCRIPTION
Rotates a stereo image.  It uses M/S methods to create a natural-sounding way to rotate the stereo image, as if you were rotating a stand holding a stereo microphone.  

SYNTAX
al, ar stereoRotate ainl, ainr, kangle

INITIALIZATION
ainl, ainr -- input audio signal

kangle -- the angle of rotation in degrees, usually in the range of -45 to +45. Negative values result in a rotation rightward. Positive values rotate leftward.

CREDITS
Joseph Anderson and ma++, jan 2005, revised 2011
*/

opcopcode stereoRotate, aa, aak

	ainl, ainr, ktheta xin

	; constants
	ipi		=	3.141592653589793
	iradfac	=	ipi/180

	;compute coeffs
	ktheta	=	iradfac*ktheta
	kstheta	=	sin(ktheta)
	kctheta	=	cos(ktheta)
	
	;Do Rotate
	aoutl		=	kctheta*ainl + kstheta*ainr
	aoutr		=	-kstheta*ainl + kctheta*ainr

	xout aoutl, aoutr

endop	
 
