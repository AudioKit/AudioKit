/*
pan_sqrt - sqrt method for panning

DESCRIPTION
Panning User Defined Opcodes
Conversion of Hans Mikelson's examples in the Csound Magazine
Autumn 1999
   http://csounds.com/ezine/autumn1999/beginners/

SYNTAX
a1, a2    pan_sqrt ain, kpan

CREDITS
Hans Mikelson, converted by Steven Yi
*/

	opcode pan_sqrt, aa, ak
asig, kpanl	xin

kpanr =      sqrt(1-kpanl)  ; Use square root of 1-kpan for the right side
kpanl =      sqrt(kpanl)    ; Take the square root for the left side
	xout asig * kpanl, asig * kpanr
	endop

 
