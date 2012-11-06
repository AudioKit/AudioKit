/*
scale - Scales incoming value to user-definable range. Similar to scale object found in popular dataflow languages.

DESCRIPTION
This opcode expects floating point input in range 0-1 and will scale this input to a minimum and maximum value variable definable at k-rate. 

This opcode is based on a formula from the Csound opcode "ctrl7" and the source formula originates in 

OOps/midiops2.c (of the Csound source tree)

and is Copyright (C) 1997 Gabriel Maldonado.

Csound source code is under the GNU Lesser General Public License and should be reviewed here:

http://www.gnu.org/copyleft/lesser.html

SYNTAX
kscl  scale   kin, kmin, kmax

PERFORMANCE
kin  --  Input value. Can originate from any k-rate source as long as that source's output is in range 0-1.

kmin  --  Minimum value of the resultant scale operation.

kmax  --  Maximum value of the resultant scale operation.

CREDITS
David Akbari  -  2005. OOps/midiops2.c - Copyright (C) 1997 Gabriel Maldonado
*/

	opcode	scale, k, kkk

kval, kmin, kmax	xin

kscl	=	kval * (kmax - kmin) + kmin

	xout	kscl

	endop
 
