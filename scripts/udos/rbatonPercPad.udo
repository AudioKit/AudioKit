/*
rbatonPercPad - Senses trigger/whack strength as well as X and Y coordinates of the two batons in a Max Mathew's Radio Baton system.

DESCRIPTION
Based on the CsoundAV opcodes by Gabriel Maldonado, this UDO reads the whack strength of the two batons as well as their respective coordinate data.

SYNTAX
kstr1, kcx1, kcy1, kstr2, kcx2, kcy2  rbatonPercPad

PERFORMANCE
** All values are integers returned in range 0-127 **

kstr1  --  The strength of the stick hitting the surface of the stick that's plugged in to the stick 1 jack.

kcx1  --  Coordinate data for the X-AXIS of stick 1.

kcy1  --  Coordinate data for the Y-AXIS of stick 1.

kstr2  --  Strength of the whack of the stick plugged into the stick 2 jack.

kcx2  --  Coordinate data for the whack of stick 2 on the X-AXIS.

kcy2  --  Coordinate data for the whack of stick 2 on the Y-AXIS.

CREDITS
David Akbari  -  2005
*/

opcode	rbatonPercPad, kkkkkk, 0

kstatus, kchan, kd1, kd2	midiin

;  trigger and whack strength - both sticks
if	(kstatus == 160 && kd1 == 1) then
kstr1	=	kd2
elseif	(kstatus == 160 && kd1 == 2) then
kstr2	=	kd2
	endif

;  stick coordinates
if	(kstatus == 160 && kd1 == 15) then
kx1	=	kd2
elseif	(kstatus == 160 && kd1 == 17) then
kx2	=	kd2
elseif	(kstatus == 160 && kd1 == 16) then
ky1	=	kd2
elseif	(kstatus == 160 && kd1 == 18) then
ky2	=	kd2
	endif

	xout	kstr1, kx1, ky1, kstr2, kx2, ky2

	endop
 
