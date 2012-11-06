/*
SigReverse - A table-based reversing opcode.

DESCRIPTION
SigReverse takes short snapshots of a signal and then plays then back in reverse.

SYNTAX
asig SigReverse ain, kfade, ifn1, ifn2

INITIALIZATION
ifn1 - table to be used to hold the recorded signal. The size of the table will determine the length of the recorded snapshot.
inf2 - window used to smooth the edges of the recorded snapshot (1/2 sine, hanning or triangle window, etc.)

PERFORMANCE
asig - reversed output

ain - input signal
kfade - this can be used to fade in/out the second playback tap, which is offset by 1/2 table in relation to the first. The second tap provides a more continuous signal, but also some echoes as side-effect

CREDITS
Victor Lazzarini, 2005
*/

opcode SigReverse, a, akii

      setksmps 1

asig,kfd,ifn,iwin xin

kwp init 0
awp = kwp

ilen = ftlen(ifn)  /* size of delay */
    tablew asig, awp, ifn  /* delay writing*/
as1 table  -kwp, ifn, 0, 0, 1  /* reverse tap 1 */
as2 table  -kwp, ifn, 0, ilen/2, 1 /* reverse tap 2 */
kenv table kwp*2,iwin, 0, 0, 1   /* crossfade envelope */
amix = as1*kenv + as2*(kenv-1)*kfd /* mix */
kwp = kwp + 1

if kwp > ilen then
kwp = 0
endif

      xout amix

endop
 
