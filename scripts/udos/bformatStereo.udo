/*
bformatStereo - Converts stereo to b-format ambisonics.

DESCRIPTION
Converts stereo to b-format ambisonics.

SYNTAX
aW, aX, aY, aZ bformatStereo aleft, aright

CREDITS
Joseph Anderson and ma++, jan 2005-- based on M. Gerzon paper 1985
*/

opcode bformatStereo, aaaa, aa
    aL, aR xin

    aLcos, aLsin hilbert aL
    aRcos, aRsin hilbert aR

    aW = .5 * (.982* aLcos + .982* aRcos + .164* aLsin - .164* aRsin)
    aX = .5 * (.419* aLcos + .419* aRcos - .828* aLsin + .828* aRsin)
    aY = .5 * (.763* aLcos - .763* aRcos + .385* aLsin + .385* aRsin)
    aZ = 0 ; no height information in uhj

    xout aW, aX, aY, aZ
endop
 
