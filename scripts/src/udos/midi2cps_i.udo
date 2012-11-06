/*
midi2cps_i - Converts MIDI Note Number to Cycles per second (Hz). (i-rate version)

DESCRIPTION
Takes a MIDI note number input and converts to Cycles per second (Hz).

SYNTAX
icps  midi2cps_i  inum

INITIALIZATION
inum  --  Expects MIDI Note # In

icps  --  Returns equivelent of MIDI Note # in Cycles per second (Hz).

CREDITS
David Akbari - 2005
*/

opcode	midi2cps_i, i, i

imid	xin

#define MIDI2CPS(xmidi) # (440.0*exp(log(2.0)*(($xmidi)-69.0)/12.0)) #
icps	=	$MIDI2CPS(imid)

	xout	icps

		endop
 
