/*
pan_gm2 - Equal Power Panning scheme defined by MIDI Association for GM2 in RP-036

DESCRIPTION
An implementation of the MIDI Association Recommend Practice for GM2 - RP-036 (Default Pan Curve).

For more information, see: http://www.midi.org/about-midi/specshome.shtml

Note: This code requires Csound 5.04 or higher


SYNTAX
aleft, aright pan_midi ain, kspace

PERFORMANCE
kspace - location of signal, from -1 (hard left) to 1 (hard right)

ain - input signal to pan

CREDITS
Steven Yi
*/

	opcode pan_midi,aa,ak

ain, kspace xin

klast init -2
kleft init 0
kright init 0

;from MIDI GM-2 Default Pan Curve (RP-036)
;Left Channel Gain [dB] = 20*log (cos (Pi/2* max(0,CC#10 – 1)/126)
;Right Channel Gain [dB] = 20*log (sin (Pi /2* max(0,CC#10 – 1)/126)

if (kspace != klast) then
 kpercent = (kspace + 1) / 2
 kleft = ampdb(20 * log(cos($M_PI_2 * kpercent)))
 kright = (kpercent == 0) ? 0 : ampdb(20 * log(sin($M_PI_2 * kpercent)))
endif

aleft = ain * kleft
aright = ain * kright

xout aleft, aright

	endop
 
 
