/*
midi2cps - Converts MIDI Note Number to Cycles per second (Hz). (k-rate version)

DESCRIPTION
Takes a MIDI note number input and converts to Cycles per second (Hz).

SYNTAX
kcps  midi2cps  knum

PERFORMANCE
knum  --  Expects MIDI Note # In

kcps  --  Returns equivelent of MIDI Note # in Cycles per second (Hz).

CREDITS
David Akbari - 2005
*/

opcode	midi2cps, k, k

kmid	xin

#define MIDI2CPS(xmidi) # (440.0*exp(log(2.0)*(($xmidi)-69.0)/12.0)) #
kcps	=	$MIDI2CPS(kmid)

	xout	kcps

		endop
 
