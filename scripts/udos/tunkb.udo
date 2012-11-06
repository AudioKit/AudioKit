/*
tunkb - k-rate microtunable MIDI to cps with pitchbend

DESCRIPTION
tunkb is the microtunable equivalent of cpsmidib

SYNTAX
kcps, kvel tunkb kfn, ibnd

INITIALIZATION
ibnd: must be greater than zero and less than two. A value of 0.5 will give a bend range of -/+ a fifth


CREDITS
Jonathan Murphy
*/

    opcode tunkb, kk, ki

  kfn, ibnd xin
  kkey	    init      0
  kvel	    init      0
	    midinoteonkey   kkey, kvel
  kcps	    cpstun    kvel, kkey, kfn
  kbend	    bends     ibnd
  kcps	    =  kcps * kbend
	    xout      kcps, kvel

    endop

 
