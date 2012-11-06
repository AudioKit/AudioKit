/*
F2M - Comverts a frequency to the next possible MIDI note number

DESCRIPTION
Comverts a frequency to the next possible MIDI note number

SYNTAX
inotenum F2M ifreq

INITIALIZATION
ifreq - input frequency
inotenum - next possible MIDI note number (middle c = 60)

CREDITS
joachim heintz sept 2010
*/

  opcode F2M, i, i
ifq xin
inotenum = round(12 * (log(ifq/220)/log(2)) + 57)
xout inotenum
  endop

 
