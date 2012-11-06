/*
ampdbN - Normalized conversion from db to amplitude.

DESCRIPTION
Converts a normalized (0 -1) db value to a normalized (0-1) amplitude value.

SYNTAX
kamp ampdbN kdb

INITIALIZATION
kdb -- a normalized db value to be converted to a normaized amplitude value, where 0 will be converted to 0 amp and 1 will be converted to 0dbfs. 

PERFORMANCE
This opcode is useful in many situations involving amplitude scaling like envelopes.

CREDITS
ma++, jan 2005
*/

opcode ampdbN, k, k

	kdb xin
	kamp = (kdb <= 0 ? 0 : ampdb(dbamp(0dbfs) * kdb)/0dbfs )
	xout kamp

endop
 
