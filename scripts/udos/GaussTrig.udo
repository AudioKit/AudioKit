/*
GaussTrig - Outputs a-rate impulses around a certain frequency.

DESCRIPTION
This UDO is modelled on the Supercollider UGen GaussTrig. It outputs a stream of impulses with control over the degree of periodicity.  

SYNTAX
aout    GaussTrig    adev, afreq, aamp

PERFORMANCE
adev - deviation from center frequency. Ranges between 0-1 where zero is no deviation. 

afreq - center frequency for the impulse generator

aamp - amplitude scaling of the output 



CREDITS
Peiman Khosravi
*/

	opcode GaussTrig,a, aaa
		adev, afreq, aamp	xin
setksmps 1
kdev 	downsamp	adev
kfreq 	downsamp	afreq
kamp	downsamp	aamp
krange = kfreq*kdev
kgauss  gauss   krange
kgauss = (kfreq+kgauss)
kgauss	limit	kgauss, .0001, sr/2
kintrvl	= 1/kgauss
ares	mpulse	kamp, kintrvl
	xout	ares	
	endop
 
