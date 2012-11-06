/*
stereoAsymmetry - Side-only panning of a stereo signal

DESCRIPTION
Rotates the side components of a stereo image, primarily keeping the center components in tact.   

SYNTAX
al, ar stereoAsymmetry ainl, ainr, kangle  

INITIALIZATION
ainl, ainr -- input audio signal 

kangle -- the angle of rotation of the side component in degrees

PERFORMANCE
This opcode uses the 'stereoMS' UDO.

CREDITS
Joseph Anderson and ma++, jan 2011
*/

opcode stereoAsymmetry, aa, aak

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
	
	;Asymmetrize
	aimagm	=	ainm - kstheta*ains
	aimags	=	kctheta*ains
	
	;Matrix	back	to	L/R
	aoutl, aoutr stereoMS	aimagm, aimags

	xout aoutl, aoutr

endop	
 
