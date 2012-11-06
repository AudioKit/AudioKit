/*
KeyOnce - Returns '1' once if a certain key has been pressed or released.

DESCRIPTION
Returns '1' once if a certain key has been pressed or released. Needs the output of a sensekey opcode. Note that just one sensekey opcode is allowed in an instrument.

SYNTAX
kdown, kup KeyOnce key, kd, kascii

PERFORMANCE
key - first output of a sensekey opcode
kd - second output of a sensekey opcode
kascii - ascii code of the key you want to check (for instance 32 for the space bar)
kdown - returns '1' in the k-cycle kascii has been pressed
kup - returns '1' in the k-cycle kascii has been released

CREDITS
joachim heintz 2010
*/

  opcode KeyOnce, kk, kkk
key, kd, kascii    xin 
knew      changed   key
kdown     =         (key == kascii && knew == 1 && kd == 1 ? 1 : 0)
kup       =         (key == kascii && knew == 1 && kd == 0 ? 1 : 0)
          xout      kdown, kup
  endop

 
