/*
cps2midi - Converts Cycles per second (Hz) to MIDI note number. (k-rate version)

DESCRIPTION
This opcode converts a Cycles per second (Hz) value into a MIDI note number (in range 0-127).

SYNTAX
knotnum  cps2midi  kcps

PERFORMANCE
knotnum  --  MIDI note number output based on Cycles per second (Hz) input.

kcps  --  Cycles per second (Hz) input.

CREDITS
Istvan Varga - 2006, Example by David Akbari
*/

opcode cps2midi, k, k
kcps    xin
        xout    logbtwo(kcps / 440) * 12 + 69
    endop
 
