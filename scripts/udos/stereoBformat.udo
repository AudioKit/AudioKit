/*
stereoBformat - Converts b-format ambisonics to uhj stereo.

DESCRIPTION
Converts b-format ambisonics to uhj stereo.

SYNTAX
aleft, aright stereoBformat aW, aX, aY, aZ

INITIALIZATION
aW, aX, aY, aZ -- the b-format signal

CREDITS
Joseph Anderson and ma++, jan 2005
*/

opcode stereoBformat, aa, aaaa

	aW, aX, aY, aZ xin	

	aWcos, aWsin hilbert aW
	aXcos, aXsin hilbert aX
	aYcos, aYsin hilbert aY

	aleft = 0.0928* aXcos + 0.255*aXsin + 0.4699* aWcos - 0.171* aWsin + 0.3277* aYcos
	aright = 0.0928* aXcos - 0.255*aXsin + 0.4699* aWcos + 0.171* aWsin - 0.3277 * aYcos

	xout aleft, aright

endop
 
