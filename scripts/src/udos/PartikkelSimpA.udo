/*
PartikkelSimpA - A simplified version of the Partikkel opcode, but with some additional parameters

DESCRIPTION
A simplified version of the Partikkel opcode, but with some additional parameters. It performs asynchronous granular synthesis with a maximal displacement of
1/grainrate seconds.

SYNTAX
aout  PartikkelSimpA ifiltab, iskip, kspeed, kgrainamp, kgrainrate, kgrainsize, kcent, kposrand, kcentrand, icosintab, idisttab, iwin

INITIALIZATION
ifiltab - function table with the input sound file (usually with GEN01)
iskip - skiptime (sec)
icosintab - function table with cosine (e.g. giCosine ftgen 0, 0, 8193, 9, 1, 1, 90)
idisttab - function table with distribution (e.g. giDisttab ftgen 0, 0, 32768, 7, 0, 32768, 1)
iwin - function table with window shape (e.g. giWin ftgen 0, 0, 4096, 20, 9, 1)

PERFORMANCE
kspeed - speed of the pointer
kgrainamp - multiplier of the grain amplitude (the overall amplitude depends also from grainrate and grainsize)
kgrainrate - number of grains per seconds
kgrainsize - grain duration in ms
kcent - transposition in cent
kposrand - random deviation (offset) of the pointer in ms
kcentrand - random transposition in cents (up and down)



CREDITS
Joachim Heintz and Oeyvind Brandtsegg 2009
*/

	opcode PartikkelSimpA, a, iikkkkkkkiii

ifiltab, iskip, kspeed, kgrainamp, kgrainrate, kgrainsize, kcent, kposrand, kcentrand, icosintab, idisttab, iwin	xin

/*length of input file*/
itablen		tableng		ifiltab
ifilsr		=		ftsr(ifiltab)
ifildur		= 		itablen / ifilsr
/*amplitude*/
kamp		= 		kgrainamp * 0dbfs
/*transposition*/
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / ifildur; original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)	
/*pointer*/
istartpos	=		iskip / ifildur; start 0-1
afilposphas	phasor 		kspeed / ifildur, istartpos
arndpos		linrand		kposrand; random offset in phase values
asamplepos	= 		afilposphas + arndpos; resulting phase values (0-1)
/* other parameters */
imax_grains	= 		1000; maximum number of grains per k-period
idist		=		1; scattered distribution
async		=		0; no sync input
awavfm		=		0; no audio input for fm

aout		partikkel 	kgrainrate, idist, idisttab, async, 1, iwin, \
				-1, -1, 0, 0, kgrainsize, kamp, -1, \
				kwavfreq, 0, -1, -1, awavfm, \
				-1, -1, icosintab, kgrainrate, 1, \
				1, -1, 0, ifiltab, ifiltab, ifiltab, ifiltab, \
				-1, asamplepos, asamplepos, asamplepos, asamplepos, \
				1, 1, 1, 1, imax_grains

		xout		aout
	endop


 
