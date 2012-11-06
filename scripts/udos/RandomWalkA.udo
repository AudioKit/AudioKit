/*
RandomWalkA - Generate random walk at a-rate

DESCRIPTION
Generate random walk at a-rate.  rnd31 outputs in range kstep and output is bound within imin and imax.

SYNTAX
aout    RandomWalkA    kstep, imin, imax, iseed

INITIALIZATION
imin - minimum of range of values

imax - maximum of range of values

iseed - seed for rnd31

PERFORMANCE
kstep - kscl for rnd31. The generated random numbers are in the range -kstep to kstep.  kstep must be less than (max-min)/2. 

CREDITS
Istvan Varga
*/

        opcode RandomWalkA, a, kiii
        setksmps 1
kstep, imin, imax, iseed        xin
k1      init (imin + imax) * 0.5
k2      rnd31 kstep, 0, iseed
k3      =  k1 + k2
k1      =  ((k3 < imin) || (k3 > imax) ? k1 - k2 : k3)
aout    upsamp k1
        xout aout
        endop 
 
