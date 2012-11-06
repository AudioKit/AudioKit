/*
ExpCurve - Normalised exponential curve with variable steepness.

DESCRIPTION
This opcode implements a formula for generating a normalised exponential curve in range 0 - 1. It is based on the Max / MSP work of Eric Singer (c) 1994.

SYNTAX
kout  ExpCurve  kfloat, ksteepness

PERFORMANCE
kfloat  --  A normalised floating point value in range 0 - 1.

ksteepness  --  Steepness index of the resulting curve. This should be > 1. There exists a safeguard in the opcode to help minimize errors related to Not-a-Number (NaN) as a result of having a steepness index of <= 1.

CREDITS
David Akbari - 2005
*/

opcode	ExpCurve, k, kk

kfloat, ksteep	xin

if (ksteep > 1) then
	ksteep = ksteep
elseif (ksteep < 1) then
	ksteep = 1
endif

kout	=	(exp(kfloat * log(ksteep)) - 1)/(ksteep - 1)

	xout	kout

		endop
 
