/*
rbatonXYZ - polls X, Y, and Z coordinates of a Max Mathew's Radio Baton.

DESCRIPTION
This opcode implements a signal interpreter from polyphonic aftertouch MIDI messages to k-rate Csound arguments. It is based on Gabriel Maldonado's implementation in CsoundAV. Unlike CsoundAV however, this implementation does NOT return normalised values and instead returns raw data bytes from the MIDI messages themselves in range 00-7F (0-127).

SYNTAX
kx1, ky1, kz1, kx2, ky2, kz2  rbatonXYZ

PERFORMANCE
kx1  --  Corresponds to the X-Axis coordinate of the Baton plugged into the stick 1 input.

ky1  --  Corresponds to the Y-Axis coordinate of the Baton plugged into the stick 1 input.

kz1  --  Corresponds to the Z-Axis coordinate of the Baton plugged into the stick 1 input.

kx2  --  Corresponds to the X-Axis coordinate of the Baton plugged into the stick 2 input.

ky2  --  Corresponds to the Y-Axis coordinate of the Baton plugged into the stick 2 input.

kz2  --  Corresponds to the Z-Axis coordinate of the Baton plugged into the stick 2 input.

It is important to note that these opcodes poll at k-rate so care must be taken in this regard.

CREDITS
David Akbari  -  2005
*/

opcode	rbatonXYZ, kkkkkk, 0

kstatus, kchan, kd1, kd2	midiin

;  stick 1 - red
if	(kstatus == 160 && kd1 == 8) then
kx1	=	kd2
elseif	(kstatus == 160 && kd1 == 9) then
ky1	= 	kd2
elseif	(kstatus == 160 && kd1 == 10) then
kz1	=	kd2
else
	endif

;  stick 2 - gray
if	(kstatus == 160 && kd1 == 11) then
kx2	=	kd2
elseif	(kstatus == 160 && kd1 == 12)	then
ky2	= 	kd2
elseif	(kstatus == 160 && kd1 == 13)	then
kz2	=	kd2
else
	endif

	xout	kx1, ky1, kz1, kx2, ky2, kz2

	endop
 
