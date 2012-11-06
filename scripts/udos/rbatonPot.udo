/*
rbatonPot - Implements a sensor for the 4 pots, 2 footswitches and B15+ button on the Max Mathew's Radio Baton unit.

DESCRIPTION
This opcode is based on the opcodes from CsoundAV by Gabriel Maldonado.

It implements sensors for each of the 4 pots on the Radio Baton unit as well as sensors for the B14- and B15- footswitches and the B15+ on the unit itself.

SYNTAX
kpot1, kpot2, kpot3, kpot4, kfsw1, kfsw2, kbtn  rbatonPot

PERFORMANCE
kpot1  --  Returns integer values from 0-127 from POT1

kpot2  --  Returns integer values from 0-127 from POT2

kpot3  --  Returns integer values from 0-127 from POT3

kpot4  --  Returns integer values from 0-127 from POT4

kfsw1  --  Returns a 1 if the footswitch plugged into the B14- jack is pressed, otherwise 0.

kfsw2  --  Returns a 1 if the footswitch plugged into the B15- jack is pressed, otherwise 0.

kbtn  --  Returns a 1 only when the B15+ button on the unit itself is pressed then immediately returns to 0.

CREDITS
David Akbari  -  2005
*/

opcode	rbatonPot, kkkkkkk, 0

kstatus, kchan, kd1, kd2	midiin

;  4-pots
if	(kstatus == 160 && kd1 == 4) then
kpot1 =	kd2
elseif	(kstatus == 160 && kd1 == 5) then
kpot2 =	kd2
elseif	(kstatus == 160 && kd1 == 6) then
kpot3 =	kd2
elseif	(kstatus == 160 && kd1 == 7) then
kpot4 =	kd2
else
	endif

;  B15+ button on the unit
if	(kstatus == 160 && (kd1 == 3 && kd2 == 1)) then
kbtn	=	1
else
kbtn	=	0
	endif
	
;  B14- footswitch 1
if	(kstatus == 160 && (kd1 == 3 && kd2 == 2)) then
kfsw1	=	1
elseif	(kstatus == 160 && (kd1 == 3 && kd2 == 3)) then
kfsw1	=	0
	endif

;  B15- footswitch 2
if	(kstatus == 160 && (kd1 == 3 && kd2 == 4)) then
kfsw2	=	1
elseif	(kstatus == 160 && (kd1 == 3 && kd2 == 5)) then
kfsw2	=	0
	endif	

	xout	kpot1, kpot2, kpot3, kpot4, kfsw1, kfsw2, kbtn

	endop
 
