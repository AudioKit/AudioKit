/*
BufRec2 - Records in a stereo buffer (= two function tables)

DESCRIPTION
Records in a stereo buffer (two function tables), with optional start point, end point, and wrap (= loop record).


SYNTAX
kfin BufRec2 ainL, ainR, iftL, iftR, krec, kstart, kend, kwrap

INITIALIZATION
iftL, iftR - function tables for recording

PERFORMANCE
ainL, ainR - audio signals to record
krec - 1 for recording, 0 (or any other number) stops recording
kstart - begin of recording into the function table in seconds
kend - end of recording into the function table in seconds
kwrap - if 1, recording wraps between kend and the beginning of the buffer (see th examples below for instr 4); if 0 (or any other number), record stops at kend
kfin - 1 if record has finished

CREDITS
joachim heintz 2010
*/

  opcode BufRec1, k, aikkkk
ain, ift, krec, kstart, kend, kwrap xin
		setksmps	1
kendsmps	=		kend*sr ;end point in samples
kendsmps	=		(kendsmps == 0 || kendsmps > ftlen(ift) ? ftlen(ift) : kendsmps)
kfinished	=		0
krec		init		0
knew		changed	krec ;1 if record just started
 if krec == 1 then
  if knew == 1 then
kndx		=		kstart * sr - 1 ;first index to write minus one
  endif
  if kndx >= kendsmps-1 && kwrap == 1 then
kndx		=		-1
  endif
  if kndx < kendsmps-1 then
kndx		=		kndx + 1
andx		=		kndx
		tabw		ain, andx, ift
  else
kfinished	=		1
  endif
 endif
 		xout		kfinished
  endop

  opcode BufRec2, k, aaiikkkk
ainL, ainR, iftL, iftR, krec, kstart, kend, kwrap xin
kfinished	BufRec1	ainL, iftL, krec, kstart, kend, kwrap
kfinished	BufRec1	ainR, iftR, krec, kstart, kend, kwrap
 		xout		kfinished
  endop
 
