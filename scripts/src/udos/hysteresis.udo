/*
hysteresis - Implements classic 2-threshold hysteresis. Useful for performance controllers.

DESCRIPTION
This User Defined Opcode implements the classic HIT / RESET threshold idea. Based on a Max/MSP implementation which is the work of Eric Singer (c) 1994.

SYNTAX
kboth, khi_tru, klo_tru  hysteresis  kin, khi_thresh, klo_thresh

PERFORMANCE
kin  --  The input value which is subject to the hysteresis thresholds.

khi_thresh  --  This is the HIGH threshold. When the value at kin exceeds this, a 1 outputs at khi_tru and kboth.

klo_thresh  --  This is the LOW threshold. When the value at kin exceeds this, a 1 is output at klo_tru.

khi_tru  --  Outputs a 1 if kin exceeds the HIGH threshold else 0.

klo_tru  --  Again, boolean output of kin exceeding LOW threshold.

kboth  --  Outputs a 1 if kin exceeds both thresholds.

CREDITS
David Akbari  -  2005
*/

opcode	hysteresis, kkk, kkk

kin, khi, klo	xin

if	(kin > klo) then
klotr	=	1
kout	=	1
	if	(kin >= khi) then
	kout	=	1
	khitr	=	1
	else
	kout	=	0
	khitr	=	0
	endif
else
kout	=	0
klotr	=	0
	endif

	xout	kout, khitr, klotr

		endop
 
