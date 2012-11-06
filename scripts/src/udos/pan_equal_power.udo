/*
pan_equal_power - Equal Power Panning

DESCRIPTION
Panning User Defined Opcodes
Conversion of Hans Mikelson's examples in the Csound Magazine
Autumn 1999
   http://csounds.com/ezine/autumn1999/beginners/

SYNTAX
a1, a2    pan_equal_power    asig, kpan

CREDITS
Author: Michael Gogins, converted by Steven Yi, Rewritten by Istvan Varga for Speed
*/

	opcode pan_equal_power, aa, ak
ain, kpan       xin
kangl   =  1.57079633 * (kpan + 0.5)
        xout    ain * sin(kangl), ain * cos(kangl)

	endop
 
