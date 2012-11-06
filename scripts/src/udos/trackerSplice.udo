/*
trackerSplice - signal splicer

DESCRIPTION
This UDO performs realtime re-triggering and reversing of samples in a style similar to that found on most audio trackers. The main difference here is that the samples are being created on the fly during run-time.  

SYNTAX
ares trackerSplice asig, ksegLength, kmode

PERFORMANCE
asig - input signal
ksegLength - length of re-triggered sample in seconds, for now max=1, if you need longer just change the size of your function table 
kmode - either 0, 1, 2 depending on what you want. 0 does no processing, 1 will re-trigger and 2 will reverse  

CREDITS
Rory Walsh. Mar 2011
*/

opcode trackerSplice, a, akk
asig, kseglength, kmode xin

setksmps 1
kindx init 0
ksamp init 1
aout init 0

itbl ftgenonce 0, 0, 2^16, 7, 0, 2^16, 0	;create table to hold samples
kseglength = kseglength*sr			;convert length to samples
andx phasor sr/ftlen(itbl)			;ensure phasor is set to correct freq
tabw asig, andx*ftlen(itbl), itbl		;write signal to table
andx1 delay andx, 1				;insert a 1 sample delay so that the read point
						;always stays one sample behind the write pointer
apos samphold andx1*ftlen(itbl), ksamp		;hold sample position whem ksamp=0

if(kmode>=1 && kmode <2) then 				;do retrigger when kmode==1
	kpos downsamp apos
	kindx = (kindx>kseglength ? 0 : kindx+1)
	if(kindx+kpos> ftlen(itbl)) then
	kindx = -kseglength
	endif
	aout table apos+kindx, itbl, 0, 1
	ksamp = 0

elseif(kmode>=2 && kmode<3) then				;do reverse when kmode==2 
	kpos downsamp apos
	kindx = ((kindx+kpos)<=0 ? ftlen(itbl)-kpos : kindx-1)
	aout table apos+kindx, itbl, 0, 1
	ksamp = 0

else 						;when kmode==0 simple pass signal through
	ksamp = 1
	aout = asig
endif
xout aout
endop
 
