/*
deflutter - deflutter k-rate input (data smoothing)

DESCRIPTION
Deflutters k-rate input. If you are using a controller to control Csound that tends to jump erratically from one value to the next, this opcode may be useful to you.

It is based on the Max / MSP work of Eric Singer (c) 1994.

SYNTAX
kout  deflutter  kin

PERFORMANCE
kout  --  k-rate defluttered output.

kin  --  input to deflutter.

CREDITS
David Akbari - 2005
*/

opcode deflutter, k, k

kval	xin

ki1	=	int(kval)
ki2	=	int(kval)
ki3	=	int(kval)
ki4	delayk	ki3, 0.1

;;
ki2	=	ki2 - ki3

if	(ki2 != 1) then
	kb1	=	1
else
	kb1	=	0
endif

if	(ki2 != -1) then
	kb3	=	1
else
	kb3	=	0
endif

;;
ki3	=	ki3 - ki4

if	(ki3 != -1)	then
	kb2	=	1
else
	kb2	=	0
endif

if	(ki3 != 1) then
	kb4	=	1
else
	kb4	=	0
endif

;;
if	(kb1 == 1 || kb2 == -1) then
	kL	=	1
else
	kL	=	0
endif

if	(kb3 == 1 || kb4 == 1) then
	kR	=	1
else
	kR	=	0
endif

if	(kL == 1 && kR == 1) then
	kgate	=	1
else
	kgate	=	0
endif

if	(kgate == 1) then
	kval	=	kval
else
	kval	=	0
endif

	xout	kval

		endop
 
