/*
linearPointer - Pointer to read a function table linearly, forwards or backwards.

DESCRIPTION
Pointer to read a function table linearly, forwards or backwards.  Output is in samples.

SYNTAX
linearPointer kspeed, kbeg, kend, ifn, [imode]

INITIALIZATION
ifn -- function table to point at
imode [optional] -- if -1 reads backwards.  all other values, reads forwards

PERFORMANCE
kspeed -- 1=no change, 2=double speed, .5=half speed
kbeg/kend -- values 0-1.  example: kbeg=.1, kend = .8 loops between .1 and .8 * tablelength. 

CREDITS
bhob rainey
*/

	opcode linearPointer, k, kkkip
kspeed, kbeg, kend, ifn, imode xin
kend limit kend, kbeg + .001, 1
kbeg limit kbeg, 0, kend
isamps = ftlen(ifn)
ilength = (isamps/sr)
kcps = kspeed/ilength
kpoint phasor kcps
kpoint = (imode == -1?kpoint * -1 + 1:kpoint)
kpoint = (kpoint * (kend-kbeg)) * isamps + kbeg * isamps
xout kpoint
	endop
 
