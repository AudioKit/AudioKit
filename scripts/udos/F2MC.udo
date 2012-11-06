/*
F2MC - converts a frequency to a MIDI.Cent note number

DESCRIPTION
converts a frequency to a MIDI.Cent note number


SYNTAX
imidicent F2MC ifreq

INITIALIZATION
ifreq - input frequency
imidicent - midi note number and cent deviation as fractional part

CREDITS
joachim heintz sept 2010
*/

  opcode F2MC, i, i
ifq xin
in1 = 12 * (log(ifq/220)/log(2)) + 57 ;'real' conversion 
in2 = floor(in1) ;next lower midi note
icent = (in1 - in2) * 100 ;cent difference
xout in2 + icent/100
  endop

 
