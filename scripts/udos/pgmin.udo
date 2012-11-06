/*
pgmin - Read program change messages from MIDI input.

DESCRIPTION
Much like the externals in popular dataflow languages (eg. MaxMSP, Pd, jMax, etc) this opcode is intended to be used where program change messages are necessary, for example to trigger events or change presets in General MIDI orchestra.

SYNTAX
kpgm, kchan  pgmin

PERFORMANCE
kpgm  -  The program change message number (0-127).
kchan -  The channel number (0-16) that the program change message was received on.

CREDITS
David Akbari, 2006
*/

	opcode	pgmin, kk, 0

kstatus, kchan, kdata1, kdata2	midiin

if	(kstatus == 192 && kchan == 1) then
kpgm	=	kdata1
else
	endif

	xout	kpgm, kchan

		endop
 
