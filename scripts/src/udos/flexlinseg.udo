/*
flexlinseg - Envelope that reads parameters from a flexible number of pfields

DESCRIPTION
flexlinseg is an envelope UDO that reads from 1 to 21 parameters from the pfields of a note event, starting with the specified pfield.  Any segments of the envelope that are not given in the pfields are set to zero.  It relies on another small UDO (mypvalue), also included below.  



SYNTAX
kenv  flexlinseg  ipstart

INITIALIZATION
ipstart is the number of the first pfield containing the envelope parameters.  flexlinseg reads the remaining pfields (up to 21 of them) and passes them to a linseg opcode.  If you need more than 21 parameters, the UDO is easy to modify.

PERFORMANCE
kenv is the output envelope.  

CREDITS
Anthony Kozar, 2006
*/

; This UDO returns a pfield value but returns 0 if it does not exist.
opcode  mypvalue, i, i
	index  xin
	inum   pcount
	if	  (index > inum)  then
		iout = 0.0
	else
		iout pindex index
	endif
	
	xout	iout
endop
	
; Envelope UDO that reads parameters from a flexible number of pfields
; Syntax:   kenv  flexlinseg  ipstart
;           ipstart is the first pfield of the envelope
;               parameters.  Reads remaining pfields (up to 21 of them).
;           kenv is the output envelope.

opcode  flexlinseg, k, i
	ipstart xin
	
	iep1   mypvalue	ipstart
	iep2   mypvalue	ipstart + 1
	iep3   mypvalue	ipstart + 2
	iep4   mypvalue	ipstart + 3
	iep5   mypvalue	ipstart + 4
	iep6   mypvalue	ipstart + 5
	iep7   mypvalue	ipstart + 6
	iep8   mypvalue	ipstart + 7
	iep9   mypvalue	ipstart + 8
	iepa   mypvalue	ipstart + 9
	iepb   mypvalue	ipstart + 10
	iepc   mypvalue	ipstart + 11
	iepd   mypvalue	ipstart + 12
	iepe   mypvalue	ipstart + 13
	iepf   mypvalue	ipstart + 14
	iepg   mypvalue	ipstart + 15
	ieph   mypvalue	ipstart + 16
	iepi   mypvalue	ipstart + 17
	iepj   mypvalue	ipstart + 18
	iepk   mypvalue	ipstart + 19
	iepl   mypvalue	ipstart + 20

	kenv   linseg	 iep1, iep2, iep3, iep4, iep5, iep6, iep7, iep8, \
	                   iep9, iepa, iepb, iepc, iepd, iepe, iepf, iepg, \
	                   ieph, iepi, iepj, iepk, iepl
	
	xout   kenv
endop

 
