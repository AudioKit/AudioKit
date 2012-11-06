/*
envelope - MIDI adsr envelope, variable release times for multiple instances.

DESCRIPTION
MIDI adsr envelope allowing differing release times for multiple instances within the same instrument, as opposed to the behaviour of the "r" family of opcodes (linsegr, expsegr et al). UDO intended as a simple example or template.

SYNTAX
  aenv	    envelope  iatt, idec, isus, irel

CREDITS
Jonathan Murphy
*/

    opcode envelope, a, iiii

  iatt, idec, isus, irel  xin
 
	    xtratim   irel
  krel	    release
if (krel == 1) kgoto rel
  aenv1	    linseg    0, iatt, 1, idec, isus
  aenv	    =  aenv1
	    kgoto     done
rel:
  aenv2	    linseg    1, irel, 0
  aenv	    =  aenv1 * aenv2
done:

	    xout      aenv

    endop
 
