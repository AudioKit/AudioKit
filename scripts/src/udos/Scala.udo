/*
Scala - Scales an incoming a-signal from a certain range to another range.

DESCRIPTION
Scales the incoming signal aval in the range between kinmin and kinmax linear to the range between koutmin and koutmax. It works exactly the same as the "scale" object in Max/MSP, but at audio-rate.

SYNTAX
aout Scala aval, kinmin, kinmax, koutmin, koutmax

PERFORMANCE
aval - incoming audio signal
kinim - minimum range of input value
kinmax - maximum range of input value
koutmin - minimum range of output value
koutmax - maximum range of output value

CREDITS
joachim heintz sept 2010
*/

  opcode Scala, a, akkkk
aval, kinmin, kinmax, koutmin, koutmax xin
ares = (((koutmax - koutmin) / (kinmax - kinmin)) * (aval - kinmin)) + koutmin
xout ares
  endop
 
