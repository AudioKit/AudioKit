/*
KeyStay - Returns '1' as long as a certain key is hold.

DESCRIPTION
Returns '1' as long as a certain key is hold. Needs the output of a sensekey opcode. Note that just one sensekey opcode is allowed in an instrument.
Make sure that automatic key repeats are disabled on your computer

SYNTAX
kstay KeyStay key, kd, kascii

PERFORMANCE
key - first output of a sensekey opcode
kd - second output of a sensekey opcode
kascii - ascii code of the key you want to check (for instance 32 for the space bar)
kstay - returns '1' as long as kascii is hold


CREDITS
joachim heintz 2010
*/

  opcode KeyStay, k, kkk
key, kd, kascii    xin 
kprev     init      0 ;previous key value
kout      =         (key == kascii || (key == -1 && kprev == kascii) ? 1 : 0)
kprev     =         (key > 0 ? key : kprev)
kprev     =         (kprev == key && kd == 0 ? 0 : kprev)
          xout      kout
  endop

 
