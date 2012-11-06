/*
stereoBalance - Stereo 'panning' using the balance technique.

DESCRIPTION
Distorts a stereo image toward a given direction. In contrast to the 'stereoRotate' UDO, this opcode distorts the stereo image by moving elements near the center a greater distance than elements on the sides. In fact, extreme left and right elements do not move at all, which can help prevent "phasey" artifacts created by 'stereoRotate'.


SYNTAX
al, ar stereoBalance ainl, ainr, kangle

INITIALIZATION
ainl, ainr -- input audio signal 

kangle -- the angle of distortion in degrees, usually in the range of -45 to +45. Negative values result in a distortion rightward. Positive values distort leftward.

CREDITS
Joseph Anderson and ma++, jan 2011  
*/

opcode stereoBalance, aa, aak

	ainl, ainr, ktheta xin

	; constants
	ipi		=	3.141592653589793
	iradfac		=	ipi/180
	isqrt2		=	1.414213562373095

	;compute coeffs
	ktheta		=	iradfac*(45-ktheta)
	kstheta		=	sin(ktheta)
	kctheta		=	cos(ktheta)
	
	;Do Balance
	aoutl		=	isqrt2 * kctheta * ainl
	aoutr		=	isqrt2 * kstheta * ainr

	xout aoutl, aoutr

endop	
 
