/*
findPowerOfTwo - Given a value in seconds, finds a power of two size equal to or greater than it in samples

DESCRIPTION
Given a value in seconds, finds a power of two size equal to or greater than it. 

SYNTAX
isamples findPowerOfTwo iseconds

CREDITS
Author: Steven Yi
*/

	opcode findPowerOfTwo, i, i

iseconds	xin

isamples	= iseconds * sr

ipowtwosamples = 2

loop:

ipowtwosamples = ipowtwosamples * 2

if ipowtwosamples < isamples igoto loop

	xout ipowtwosamples

	endop
 
