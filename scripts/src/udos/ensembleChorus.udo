/*
ensembleChorus - A stereo chorus opcode with multiple voices.

DESCRIPTION
A stereo chorus opcode with multiple voices.
User can control how many voices.

SYNTAX
al, ar ensembleChorus ain, kdelay, kdpth, kminrate, kmaxrate, inumvoice, iwave

INITIALIZATION
inumvoice -- number of voices
iwave -- function table for the lfo wave (sine, triangle, etc).  

PERFORMANCE
kdelay -- delay time in seconds
kdepth -- chorus depth in seconds
kminrate/kmaxrate -- min and max lfo rates (cps)

CREDITS
bhob rainey
*/

	opcode ensembleChorus, aa, akkkkiip
ain, kdelay, kdpth, kmin, kmax, inumvoice, iwave, icount xin
incr = 1/(inumvoice)

if (icount == inumvoice) goto out
ainl, ainr ensembleChorus ain, kdelay, kdpth, kmin, kmax, inumvoice, iwave, icount + 1

out:

max:
imax = i(kmax)
if (kmax != imax) then 
reinit max
endif

iratemax unirand imax
rireturn
alfo oscil kdpth, iratemax + kmin, iwave
adel vdelay3 ain/(inumvoice * .5), (kdelay + alfo) * 1000, 1000
al = ainl + adel * incr * icount
ar = ainr + adel * (1 - incr * icount)
xout al, ar
	endop
 
