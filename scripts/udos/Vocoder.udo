/*
Vocoder - channel vocoder with user-specified number of bands

DESCRIPTION
Vocoder is a channel vocoder using 4th order butteworth filters. It takes an input signal and analyses it with a user-specified number of log-spaced (constant-Q) filter bands (between a min and max) and  frequency) and then applies the analysed spectral envelope to an excitation signal.

SYNTAX
asig Vocoder aexc, ain, kminf, kmaxf, kq, ibands

INITIALIZATION
ibands - number of filter bands between kminf and kmaxf

PERFORMANCE
asig - output
aexc - excitation signal, generally a broadband source (ie. lots of spectral components)
ain - input signal, generally a signal with a strong spectral envelope or contour, formants, etc. (such as vocal sound)
kminf - lowest analysis frequency
kmaxf - highest analysis frequency
kq - filter Q 


CREDITS
Victor Lazzarini, 2005
*/

opcode Vocoder, a, aakkkpp

as1,as2,kmin,kmax,kq,ibnd,icnt  xin

if kmax < kmin then
ktmp = kmin
kmin = kmax
kmax = ktmp
endif

if kmin == 0 then 
kmin = 1
endif

if (icnt >= ibnd) goto bank
abnd   Vocoder as1,as2,kmin,kmax,kq,ibnd,icnt+1

bank:
kfreq = kmin*(kmax/kmin)^((icnt-1)/(ibnd-1))
kbw = kfreq/kq
an  butterbp  as2, kfreq, kbw
an  butterbp  an, kfreq, kbw
as  butterbp  as1, kfreq, kbw
as  butterbp  as, kfreq, kbw
ao balance as, an

amix = ao + abnd

     xout amix

endop
 
