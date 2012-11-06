/*
boomerangPointer - Pointer to read a function table forwards then backwards or vice versa.

DESCRIPTION
Pointer to read a function table forwards then backwards or vice versa.

SYNTAX
boomerangPointer kspeed, kbeg, kend, ifn, [imode]

INITIALIZATION
ifn -- function table to point at 
imode [optional] -- if -1 reads backwards then forwards. all other values, reads forwards then backwards

PERFORMANCE
kspeed -- 1=no change, 2=double speed, .5=half speed 
kbeg/kend -- values 0-1. example: kbeg=.1, kend = .8 loops between .1 and .8 * tablelength

CREDITS
bhob rainey
*/

	opcode boomerangPointer, k, kkkip
;imode default = forward/backward, -1 = backward/forward
kspeed, kbeg, kend, ifn, imode xin
kend limit kend, kbeg + .001, 1
kbeg limit kbeg, 0, kend
isamps = ftlen(ifn)
ilength = (isamps/sr) * 2
kcps = kspeed/ilength
kpoint loopseg kcps, 0, 0, 0, kcps * 2, 1, kcps * 2, 0, 0
kpoint = (imode == -1?kpoint * -1 + 1:kpoint)
kpoint = (kpoint * (kend-kbeg)) * isamps + kbeg * isamps
xout kpoint
	endop
 
