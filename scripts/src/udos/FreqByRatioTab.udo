/*
FreqByRatioTab - frequency calculation of a step of a scale which is defined by a list of proportions

DESCRIPTION
frequency calculation of a step of a scale which is defined by a list of proportions

SYNTAX
ifreq			FreqByRatioTab	iftratio, iref_freq, iumult, istep

INITIALIZATION
iftprops:	function table with the number of proportions per unit multiplier (usually 2 = octave). the first value must be 1 and matches iref_freq, if istep == 0. the size of the table must be equal to the number of proportions in it (use -size and -2 as GEN)
iref_freq:	reference frequency (= for istep == 0)
iumult:	unit multiplier (2 = octave, 3 = duodecime or whatever)
istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)


CREDITS
joachim heintz 1/2010
*/

  opcode FreqByRatioTab, i, iiii
;;
iftprops, iref_freq, iumult, istep xin
itablen	=		ftlen(iftprops)
ipos 		=		floor(istep/itablen); "octave" position
ibasfreq	=		(iumult ^ ipos) * iref_freq; base freq of istep
ipropindx	=		istep % itablen; position of the appropriate proportion ...
ipropindx	=		(ipropindx < 0 ? (itablen + ipropindx) : ipropindx); ... in the table
iprop		tab_i		ipropindx, iftprops; get proportion
ifreq		=		ibasfreq * iprop; get frequency
		xout		ifreq
  endop

 
