/*
cps2midi_i - Converts Cycles per second (Hz) to MIDI note number. (i-rate version)

DESCRIPTION
Converts Cycles per second (Hz) to MIDI note number. Works at i-rate.

SYNTAX
inotnum  cps2midi_i  icps

INITIALIZATION
inotnum  --  MIDI note number, converted from Hz.

icps  --  Cycles per second (Hz) input.

CREDITS
Istvan Varga - 2006, Example by David Akbari
*/

opcode cps2midi_i, i, i
icps    xin
        xout    logbtwo(icps / 440) * 12 + 69
    endop
 
