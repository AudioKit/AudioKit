/*
tunk - k-rate microtunable MIDI to cps

DESCRIPTION
converts MIDI note numbers to microtunable cps at k-rate, also provides k-rate velocity and allows tuning changes

SYNTAX
kcps, kvel tunk kfn

CREDITS
Jonathan Murphy
*/

    opcode tunk, kk, k

  kfn	    xin
	      
  kkey	    init      0
  kvel	    init      0
	    midinoteonkey   kkey, kvel

  kcps	    cpstun    kvel, kkey, kfn

	    xout      kcps, kvel

    endop
 
