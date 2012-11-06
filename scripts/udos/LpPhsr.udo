/*
LpPhsr - creates a time pointer for loops

DESCRIPTION
creates a time pointer signal for typical loop applications, for instance in the mincer opcode, with optional backward playing

SYNTAX
atimpt LpPhsr kloopstart, kloopend, kspeed, kdir, irefdur

INITIALIZATION
irefdur - the overall duration. must be in the same scale as kloopstart and kloopend (e.g. seconds)

PERFORMANCE
kloopstart - starting point of the loop (in the scale of irefdur)
kloopend - end point of the loop (in the scale of irefdur)
kspeed - 1 = normal speed, 0.5 = half speed, etc.
kdir - 1 = forward, -1 = backward

CREDITS
joachim heintz 2011
*/

  opcode LpPhsr, a, kkki
kloopstart, kloopend, kdir, irefdur xin
kstart01   =            kloopstart/irefdur ;start in 0-1 range
kend01	   =	        kloopend/irefdur ;end in 0-1 range
ifqbas	   =	        1 / irefdur ;phasor frequency for the whole irefdur range
kfqrel	   =            ifqbas / (kend01-kstart01) * kspeed ;phasor frequency for the selected section
andxrel    phasor       kfqrel*kdir ;phasor 0-1
atimpt     =	        andxrel * (kloopend-kloopstart) + kloopstart ;adjusted to start and end
           xout         atimpt
  endop
 
