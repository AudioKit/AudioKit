/*
FreqByCentTab - frequency calculation of a step of a scale which is defined by a list of cent values

DESCRIPTION
frequency calculation of a step of a scale which is defined by a list of cent values

SYNTAX
ifreq			FreqByCentTab	iftcent, iref_freq, iumult, istep

INITIALIZATION
iftcent:	function table with the number of cent values per unit multiplier (usually 2 = octave). the first value must be 0 and matches iref_freq, if istep == 0. the size of the table must be equal to the number of cent values in it (use -size and -2 as GEN)
iref_freq:	reference frequency (= for istep == 0)
iumult:	unit multiplier (2 = octave, 3 = duodecime or whatever)
istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)

CREDITS
joachim heintz 1/2010
*/

  opcode FreqByCentTab, i, iiii
;iftcent:	function table with the number of cent values per unit multiplier (usually 2 = octave)
	;the first value must be 0 and matches iref_freq, if istep == 0
	;the size of the table must be equal to the number of cent values in it (use -size and -2 as GEN)
;iref_freq:	reference frequency (= for istep == 0)
;iumult:	unit multiplier (2 = octave, 3 = duodecime or whatever)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iftcent, iref_freq, iumult, istep xin
itablen	=		ftlen(iftcent)
ipos 		=		floor(istep/itablen); "octave" position
ibasfreq	=		(iumult ^ ipos) * iref_freq; base freq of istep
icentindx	=		istep % itablen; position of the appropriate centvalue ...
icentindx	=		(icentindx < 0 ? (itablen + icentindx) : icentindx); ... in the table
icent		tab_i		icentindx, iftcent; get cent value
ifreq		=		ibasfreq * cent(icent); get frequency
		xout		ifreq
  endop

 
