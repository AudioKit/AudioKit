/*
Residual - extracts stochastic components (transients etc) from a sound (using csound 5 opcodes)

DESCRIPTION
Residual takes in a signal, analyses it in terms of stable partials and then subtracts the stochastic, noise-based, components of the sound, which form the output of the opcode. This UDO uses new opcodes found in csound 5 only.

SYNTAX
asig Residual  ain, ifftsize

INITIALIZATION
ifftsize - length of the FFT analysis in samples

PERFORMANCE
asig - residual output
ain - signal input

CREDITS
Victor Lazzarini, 2005
*/

opcode Residual, a, ai

ain,isiz  xin 
ihsiz = isiz/4
ffr,fphs  pvsifd   ain, isiz, ihsiz, 1
ftrk      partials ffr, fphs, 0, 1, 3, 500
aout      sinsyn   ftrk, 2, 500, 1
asd       delayr   isiz/sr
asig      deltapn  isiz-ihsiz
          delayw   ain
          xout     asig-aout

endop
 
