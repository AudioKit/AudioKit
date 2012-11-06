/*
Scalk - Scales an incoming k-signal from a certain range to another range.

DESCRIPTION
Scales the incoming value kval in the range between kinmin and kinmax linear to the range between koutmin and koutmax. It works exactly the same as the "scale" object in Max/MSP.

SYNTAX
kout Scalk kval, kinmin, kinmax, koutmin, koutmax

PERFORMANCE
kval - incoming value
kinim - minimum range of input value
kinmax - maximum range of input value
koutmin - minimum range of output value
koutmax - maximum range of output value

CREDITS
joachim heintz sept 2010
*/

  opcode Scalk, k, kkkkk
kval, kinmin, kinmax, koutmin, koutmax xin
kres = (((koutmax - koutmin) / (kinmax - kinmin)) * (kval - kinmin)) + koutmin
xout kres
  endop

 
