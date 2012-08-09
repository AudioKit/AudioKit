<CsoundSynthesizer>

<CsOptions>
-odac -dm0 -+rtmidi=null -+rtaudio=null -+msg_color=0
</CsOptions>

<CsInstruments>
;HEADER
nchnls = 2
sr = 44100
0dbfs = 1.000000
ksmps = 256

;INSTRUMENTS
instr AudioFilePlayer1
giSoundFileTable1 ftgentmp 0, 0, 0, 1, "hellorcb.aif", 0, 0, 0
gaLoopingOscillator11L loscil3 1, 1, giSoundFileTable1, 1
gaReverb2L, gaReverb2R reverbsc gaLoopingOscillator11L, gaLoopingOscillator11L, 0.850000, 12000
outs gaReverb2L, gaReverb2R
endin



</CsInstruments>
<CsScore>

;F-STATEMENTS
f0 100000



</CsScore>
</CsoundSynthesizer>