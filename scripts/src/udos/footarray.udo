/*
footarray - Interface for a foot array which outputs program change MIDI messages. Can be used with any MIDI program change capable device.

DESCRIPTION
This opcode is an interpreter for a foot array which outputs MIDI program change messages. It is feasible to use this opcode with any hardware or software application that is capable of generating MIDI program change messages. A diagram of the foot array is something like

--------------------
|  0  |  1  |  2  |  3  |  4  |
|  5  |  6  |  7  |  8  |  9  |
--------------------

where the numbers correspond to the decimal equivelent of the Data Byte 1 of the MIDI message.

SYNTAX
knum, kval  footarray

PERFORMANCE
knum  --  Number of the Program Change message.

kval  --  True / False (0/1). Sends a 1 each time a controller message and immediately resets.

CREDITS
David Akbari  -  2005. Thanks to Istvan Varga for suggesting an improvement!
*/

opcode	footarray, kk, 0

kstatus, kchan, kd1, kd2	midiin

kval  =  0

if	(kstatus == 176 && kd1 == 32) then
kval	=	0
elseif	(kstatus == 192) then
knum	=	kd1
kval	=	1
	endif

	xout	knum, kval

	endop
 
