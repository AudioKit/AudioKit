/*
bformatQuad - Converts quadrophonic to b-format.

DESCRIPTION
Converts quadrophonic to b-format.

SYNTAX
aW, aX, aY, aZ bformatQuad aFL, aFR, aRL, aRR

CREDITS
Joseph Anderson and ma++, jan 2005
*/

opcode bformatQuad, aaaa, aaaa
	aFL, aFR, aRL, aRR xin

	; ignore z channel, as no height information in quad
	aW     =  aFL + aFR + aRL + aRR
	aX     =  aFL + aFR - aRL - aRR
	aY     =  aFL - aFR + aRL - aRR
	aZ     =  0   

	xout aW, aX, aY, aZ
endop
 
