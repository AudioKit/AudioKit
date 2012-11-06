/*
FreqByEqScale - frequency calculation for one step of an equal tempered scale

DESCRIPTION
frequency calculation for one step of an equal tempered scale. the unit for the scale can be an octave, a duodecim, or whatever

SYNTAX
ifreq			FreqByEqScale	iref_freq, iumult, istepspu, istep

INITIALIZATION
iref_freq:	reference frequency
iumult:	unit multiplier (2 = octave, 3 = Bohlen-Pierce scale, 5 = stockhausen scale in Studie2)
istepspu:	steps per unit (12 for semitones, 13 for complete Bohlen-Pierce scale, 25 for studie2 scale)
istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)

CREDITS
joachim heintz 1/2010
*/

  opcode FreqByEqScale, i, iiii
iref_freq, iumult, istepspu, istep xin
ifreq		=		iref_freq * (iumult ^ (istep / istepspu))
		xout		ifreq
  endop

 
