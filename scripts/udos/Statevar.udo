/*
Statevar - A digital version of the analogue state variable filter.

DESCRIPTION
This filter implements the state variable filter 
design, with individual controls for centre/cutoff
frequency and resonance. It outputs four filter signals simultaneously: high-pass, low-pass, band-pass and band-reject.

This is version 2 of this UDO (revised 25/nov/04). In order to make this an all-frequency stable filter, there is a damping limiter, which will impose a limit on the resonance factor of the filter, usually at high frequencies.


SYNTAX
ahp,alp,abp,abr   Statevar  asig, kcf, kres

PERFORMANCE
asig - input signal
kcf  - filter cutoff/centre frequency
kres - filter resonance 

CREDITS
Author: Victor Lazzarini
*/

opcode Statevar, aaaa, akk

    setksmps 1

abpd init 0
alpd init 0
alp  init 0
ipi = 4.*taninv(1);

asig,kcf,kres   xin

kf = 2*sin(ipi*kcf/(3*sr))
kq = 1/kres
klim = ((2-kf)/2)*0.33

if kq < klim then
kq = klim
endif

ahp = asig - kq*abpd - alp 
abp = ahp*kf + abpd
alp = abpd*kf + alpd
abr = alp + ahp
abpd = abp
alpd = alp 

ahp = asig - kq*abpd - alp 
abp = ahp*kf + abpd
alp = abpd*kf + alpd
abr = alp + ahp
abpd = abp
alpd = alp  

ahp = asig - kq*abpd - alp 
abp = ahp*kf + abpd
alp = abpd*kf + alpd
abr = alp + ahp
abpd = abp
alpd = alp 
  
      xout  ahp,alp,abp,abr
	
endop
 
