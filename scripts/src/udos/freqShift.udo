/*
freqShift - Detunes an audio signal

DESCRIPTION
Frequency shifting, or single sideband amplitude modulation. Frequency shifting is similar to ring modulation, except the upper and lower sidebands are separated into individual outputs. By using only one of the outputs, the input signal can be "detuned," where the harmonic components of the signal are shifted out of harmonic alignment with each other, e.g. a signal with harmonics at 100, 200, 300, 400 and 500 Hz, shifted up by 50 Hz, will have harmonics at 150, 250, 350, 450, and 550 Hz.

SYNTAX
aout freqShift ain, kfreq

INITIALIZATION
ain -- input audio signal
kfreq -- modualtion frequency

CREDITS
Sean Costello, 1999 - converted to UDO by ma++
*/

opcode freqShift, a, ak
  
	ain, kfreq	xin
	
	; Phase quadrature output derived from input signal.
	areal, aimag hilbert ain
	 
	; Sine table for quadrature oscillator.
	iSineTable ftgen	0, 0, 16384, 10, 1

	; Quadrature oscillator.
	asin oscili 1, kfreq, iSineTable
	acos oscili 1, kfreq, iSineTable, .25
	 
	; Use a trigonometric identity. 
	; See the references for further details.
	amod1 = areal * acos
	amod2 = aimag * asin
	
	; Both sum and difference frequencies can be 
	; output at once.
	; aupshift corresponds to the sum frequencies.
	aupshift = (amod1 + amod2) * 0.7
	; adownshift corresponds to the difference frequencies. 
	adownshift = (amod1 - amod2) * 0.7
	
	; Notice that the adding of the two together is
	; identical to the output of ring modulation.
	
	xout aupshift
endop
 
