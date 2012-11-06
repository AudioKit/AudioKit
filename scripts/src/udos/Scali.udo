/*
Scali - Scales an incoming i-variable from a certain range to another range.

DESCRIPTION
Scales the incoming value ival in the range between iinmin and iinmax linear to the range between ioutmin and ioutmax. It works exactly the same as the "scale" object in Max/MSP, but at init-rate (see Scalk and Scala for versions at k- and a-rate)

SYNTAX
iout Scali ival, iinmin, iinmax, ioutmin, ioutmax

INITIALIZATION
ival - incoming value
iinim - minimum range of input value
iinmax - maximum range of input value
ioutmin - minimum range of output value
ioutmax - maximum range of output value

CREDITS
joachim heintz sept 2010
*/

  opcode Scali, i, iiiii
ival, iinmin, iinmax, ioutmin, ioutmax xin
ires = (((ioutmax - ioutmin) / (iinmax - iinmin)) * (ival - iinmin)) + ioutmin
xout ires
  endop
 
