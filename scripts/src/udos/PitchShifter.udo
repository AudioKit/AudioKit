/*
PitchShifter - Delay-line pitchshifter

DESCRIPTION
PitchShifter transposes a signal by a given ratio using variable delay lines.

SYNTAX
asig PitchShifter ain, kpitch, kfdb, kdel, iwin 

INITIALIZATION
iwin - function table containg a window used to crossfade between two delay line taps. A triangular window or similar is indicated.

PERFORMANCE
asig - pitch shifted output
ain - input signal
kpitch - pitch shift ratio
kfdb - feedback amount (0-1]. Feedback can be used for arpeggiation effects.
kdel - delay line length (s). It is often useful to set the delaytime as 1/(f0*0.5) when pitchshifting monophonic pitched signals, to avoid artifacts

*/

opcode  PitchShifter, a, akkki 
        setksmps  1                   ; kr=sr 
asig,kpitch,kfdb,kdel,iwin  xin 
kdelrate = (kpitch-1)/kdel 
avdel   phasor -kdelrate               ; 1 to 0 
avdel2  phasor -kdelrate, 0.5          ; 1/2 buffer offset  
afade  tablei avdel, iwin, 1, 0, 1     ; crossfade windows 
afade2 tablei avdel2,iwin, 1, 0, 1 
adump  delayr 1                  
atap1  deltapi avdel*kdel     ; variable delay taps 
atap2  deltapi avdel2*kdel 
amix   =   atap1*afade + atap2*afade2  ; fade in/out the delay taps 
       delayw  asig+amix*kfdb          ; in+feedback signals 
       xout  amix 
endop
 
