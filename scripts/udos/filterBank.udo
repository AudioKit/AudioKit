/*
filterBank - Defines a bank of bandpass filters in parallel whose outputs can be scaled using a function table.

DESCRIPTION
Defines a bank of bandpass filters in parallel whose outputs can be scaled using a function table.  Kind of like resony, but with scaling.  

Storing the scaling values in a function table allows you to do some pretty cool things without writing a lot of code.  You can have several different 'eq' settings in different function tables and ftmorf through them with an lfo or step sequencer.  You can put values into the ftable using pvsftw and do some nice cross-synthesis.  then you can modulate klow/khigh (the lowest and highest cf's) and/or kres, and seriously distort the original fsig; etc.  

SYNTAX
asig filterBank klow, khigh, kres, ifn, inum, icount

CREDITS
Author: Bhob Rainey
*/

	opcode	filterBank, a, akkkiip

asig, klow, khigh, kres, ifn, inum, icount	xin

if icount> inum	goto	out

ain 	filterBank asig, klow, khigh, kres, ifn, inum, icount+ 1

out:

kcf 	= klow+ (((khigh-klow)/inum)* (icount-1))

kscale 	table icount-1, ifn
abp 	butterbp asig, kcf,kcf * kres
aout 	= ain+ abp* kscale

	xout aout
	
	endop
 
