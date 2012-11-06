/*
sittinginaroom - A simple,recursive opcode that has pleasant effects.  The name pretty much describes what it does.

DESCRIPTION
A simple,recursive opcode that has pleasant effects.  The name pretty much describes what it does.

imix should be pretty low, (.1 and lower, depending on the ir), andicount > 5 with a room-type ir usually produces the end of "i amsitting in a room".  there's a delay at the beginning of the renderedfile, equal to the usual convolve delay * icount.  i tried to do itwith pconvolve, but got mysterious performance errors.  

SYNTAX
aout sittinginaroom 
asig, imix, icount

CREDITS
Author: Bhob Rainey
*/

	opcode	sittinginaroom, a, aii

asig, imix, icount	xin

if icount==0 goto skip

asig sittinginaroom asig, imix, icount- 1

skip:

aout	convolve 	asig*imix, "impulse.cv"

xout	aout

	endop
 
