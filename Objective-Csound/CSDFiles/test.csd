 <CsoundSynthesizer>

<CsOptions>
-odac -dm0 -+rtmidi=null -+rtaudio=null -+msg_color=0
</CsOptions>

<CsInstruments>
;HEADER
sr = 44100
0dbfs = 1.000000
ksmps = 256

;INSTRUMENTS
instr 1
iCSDSineTable0x85489a0 ftgentmp 0, 0, 4096, 10, 1.000000, 0.500000, 1.000000
aCSDOscillator0x815f190 oscil 0.400000, p4, iCSDSineTable0x85489a0
aCSDReverb0x81619a0L, aCSDReverb0x81619a0R reverbsc aCSDOscillator0x815f190, aCSDOscillator0x815f190, 0.850000, 12000
out aCSDReverb0x81619a0L

endin


</CsInstruments>
<CsScore>

;F-STATEMENTS
f0 100000

i1 0 1.00 660.00 



</CsScore>
</CsoundSynthesizer>
