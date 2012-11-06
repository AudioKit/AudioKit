/*
lowpass - A k-rate smoothing UDO that is useful for averaging performance controller data.

DESCRIPTION
This opcode implements a smoothing algorithm which is intended for use with alternate controllers. It takes a data-value input and a power (filter strength) input outputting of course, the smoothed data.

SYNTAX
kout  lowpass  kin, kpow

PERFORMANCE
kin  --  Data to be smoothed.

kpow  --  Strength of the filter.

kout  -- Smoothed data.

CREDITS
David Akbari  -  2005
*/

opcode	lowpass, k, kk

klp	init	0

kval, kpowr	xin

kpow	pow	1.037, kpowr
kpow	=	kpow - 1

klp	=	((kpow * klp) + kval)/(kpow+1)

	xout	klp

		endop
 
