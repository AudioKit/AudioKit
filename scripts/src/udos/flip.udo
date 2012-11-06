/*
flip - Flips an incoming floating point value at k-rate.

DESCRIPTION
This opcode is mostly intended for use with MIDI and OSC controllers but it can likely be used for other things as well.

SYNTAX
kval  flip  kin, kmax

PERFORMANCE
kmax  --  Maximum value to flip.

kin  --  Input floating point variable.

kval  --  Resulting flipped output.

For example, if your kmax was 0, and your MIDI controller is sending values in range 0 - 127, putting it through flip would return values in range -0.000000 to -127.000000.

CREDITS
David Akbari - 2005
*/

opcode	flip, k, kk
kin, kmax	xin

kout	=	(kmax - kin)

	xout	kout
		endop
 
