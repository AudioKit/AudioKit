/*
MTXnormalizerows - Normalizes all rows in a matrix so the sum of each row is 1

DESCRIPTION
Normalizes all rows in a matrix so the sum of each row is 1

SYNTAX
idiscard MTXnormalizerows imtxnum

INITIALIZATION
idiscard- Discarded
imtxnum - ftable number of the matrix to be normalized.
This UDO is useful to normalize all rows in a MTX* matrix for use in probablilty settings like Markov chains.

CREDITS
Andres Cabrera
*/

	opcode MTXnormalizerows,i,i

imtxnum xin

icountx init 0
icounty init 0
icountz init 0

itotal init 0
isizex tablei 0, imtxnum
isizey tablei 1, imtxnum
isizez tablei 2, imtxnum
MTXnormalize:
ival tablei (icountz*isizex*isizey) + (icounty*isizex) + icountx + 3, imtxnum
itotal = itotal + ival

loop_lt icountx, 1, isizex, MTXnormalize
itotal = (itotal==0 ? 1: itotal)
vmult_i imtxnum, (1/itotal), isizex, 3 + (icountz*isizex*isizey) + (icounty*isizex)
icountx = 0
itotal = 0
loop_lt icounty, 1, isizey, MTXnormalize
icounty = 0
loop_lt icountz, 1, isizez, MTXnormalize

xout 0

	endop
 
