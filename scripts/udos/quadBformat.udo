/*
quadBformat - Converts b-format to quadrophonic.

DESCRIPTION
Converts b-format to quadrophonic.

SYNTAX
aFL, aFR , aRL, aRR quadBformat aW, aX, aY, aZ

CREDITS
Joseph Anderson and ma++, jan 2005
*/

opcode quadBformat, aaaa, aaaa
	aW, aX, aY, aZ xin

	; ignore z channel, as no height information in quad
	aFL     =  aW + aX + aY         /* front left           */
	aFR     =  aW + aX - aY         /* front right          */
	aRL     =  aW - aX + aY         /* rear left            */
	aRR     =  aW - aX - aY         /* rear right           */

	xout aFL, aFR , aRL, aRR
endop
 
