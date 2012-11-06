/*
PartikkelSimpB - The same as PartikkelSimpA, but with a time pointer input

DESCRIPTION
The same as PartikkelSimpA, but with a time pointer input

SYNTAX
apartikkel PartikkelSimpB ifiltab, apnter, kgrainamp, kgrainrate, kgrainsize, kcent, kposrand, kcentrand, icosintab, idisttab, iwin

INITIALIZATION
ifiltab:	function table with the input sound file (usually with GEN01)
icosintab:	function table with cosine (e.g. giCosine ftgen 0, 0, 8193, 9, 1, 1, 90)
idisttab:	function table with distribution (e.g. giDisttab ftgen 0, 0, 32768, 7, 0, 32768, 1)
iwin:		function table with window shape (e.g. giWin ftgen 0, 0, 4096, 20, 9, 1)

PERFORMANCE
apnter:	pointer into the function table (0-1)
kgrainamp:	multiplier of the grain amplitude (the overall amplitude depends also on grainrate and grainsize)
kgrainrate:	number of grains per seconds
kgrainsize:	grain duration in ms
kcent:		transposition in cent
kposrand:	random deviation (offset) of the pointer in ms
kcentrand:	random transposition in cents (up and down)


CREDITS
joachim heintz 2010
*/

  opcode PartikkelSimpB, a, iakkkkkkiii

ifiltab, apnter, kgrainamp, kgrainrate, kgrainsize, kcent, kposrand, kcentrand, icosintab, idisttab, iwin	xin

/*amplitude*/
kamp		= 		kgrainamp * 0dbfs
/*transposition*/
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / (ftlen(ifiltab)/sr); original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)	
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
				-1, apnter, apnter, apnter, apnter, \
				1, 1, 1, 1, imax_grains
		xout		aout
  endop

 
