/*
pan_simple - Simple Linear Pan

DESCRIPTION
Panning User Defined Opcodes
Conversion of Hans Mikelson's examples in the Csound Magazine
Autumn 1999
   http://csounds.com/ezine/autumn1999/beginners/

SYNTAX
a1, a2    pan_simple    ain, kpanl

CREDITS
Author: Hans Mikelson, converted by Steven Yi
*/

	opcode pan_simple, aa, ak
asig, kpanl	xin
kpanr 	= 1 - kpanl         
      	xout   kpanl*asig, kpanr*asig 
	endop
 
