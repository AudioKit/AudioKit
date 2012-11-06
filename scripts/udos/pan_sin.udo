/*
pan_sin - Pan using Sin/Cos to create more even power between channels

DESCRIPTION
Panning User Defined Opcodes
Conversion of Hans Mikelson's examples in the Csound Magazine
Autumn 1999
   http://csounds.com/ezine/autumn1999/beginners/

SYNTAX
a1, a2    pan_sin asig, kpan

CREDITS
Author: Hans Mikelson, converted by Steven Yi
*/

	opcode pan_sin, aa, ak
asig, kpan		xin
kpan 	= kpan*3.14159265*.5
kpanl 	= sin(kpan)
kpanr 	= cos(kpan)
	xout asig * kpanl, asig * kpanr
	endop
 
