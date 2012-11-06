/*
stereoMpan - Middle panorama panning of the 'M' component of a stereo signal

DESCRIPTION
Rotates the center components of a stereo image, primarily keeping the side components in tact.


SYNTAX
al, ar stereoMpan ainl, ainr, kangle  

INITIALIZATION
ainl, ainr -- input audio signal 

kangle -- the angle of rotation in degrees, usually in the range of -45 to +45. Negative values result in a rotation rightward. Positive values rotate leftward.


PERFORMANCE
This opcode uses the 'stereoMS' UDO.

CREDITS
Joseph Anderson and ma++, jan 2011  
*/

opcode stereoMpan, aa, aak

	ainl, ainr, ktheta xin

	; constants
	ipi		=	3.141592653589793
	iradfac	=	ipi/180

	;compute coeffs
	ktheta	=	iradfac*ktheta
	kstheta	=	sin(ktheta)
	kctheta	=	cos(ktheta)

	;Matrix	L/R	soundin	to	M/S
	ainm, ains	stereoMS	ainl, ainr
	
	;Pan M
	aimagm	=	kctheta*ainm
	aimags	=	kstheta*ainm + ains
	
	;Matrix	back	to	L/R
	aoutl, aoutr stereoMS	aimagm, aimags

	xout aoutl, aoutr

endop	
 
