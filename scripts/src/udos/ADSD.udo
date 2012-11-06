/*
ADSD - An envelope generator modelling the classic analogue ADSD envelopes

DESCRIPTION
This UDO models the classic Attack-Decay-Sustain-Decay envelope generators found in analogue synthesisers. The envelope operation depends on a control signal. When this is high (1) the envelope cycles through its stages, when it is low (2), the envelope output is zero.

SYNTAX
ksig ADSD imax, iatt, idec, isus, ktrig

INITIALIZATION
imax - max output level of envelope after attack
iatt - attack time in seconds
idec - decay time in seconds
isus - sustain output level


PERFORMANCE
ktrig - trigger control signal. When high (1), the envelope cycles through its stages, holding at the sustain level. When 0, the output of the envelope is 0. The decay time controls the time from max amp to sus levels, as well as from sus to 0, after ktrig becomes 0.

*/

opcode ADSD,k,iiiik
 imax,iatt,idec,isus,ktrig    xin 

 ktime init 0
 kv init 0
 iper = 1/kr

 if (ktrig == 1) then
   ktime = ktime + iper
   if ktime < iatt then
     kt  = iatt 
     kv = imax
   else 
     kt = idec
     kv = isus
   endif
 else
   kv = 0
   ktime = 0
 endif

 kenv  portk  kv, kt
            xout  kenv

endop
 
