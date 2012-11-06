/*
pvshift - Pitch shifting and spectral stretching with pvs streams

SYNTAX
pvshift kpitch, kstretch, inumbins, iampin, iampout, ifreqin, ifreqout

CREDITS
Author: Matt Ingalls
*/

	opcode pvshift, 0, kkiiiii

; our input values are:
; kpitch - pitch shift amount [.5=down octave,
; 1=noshift, 2=up octave, etc]
; kstretch - spectral shift amount [ususal range is
; .99-1.01, where 1=nostretch]
; inumbins - number of fft bins [size of tables]
; iampin - table containing amp data
; iampout - table to write modified amp data
; ifreqin - table containing freq data
; ifreqout - table to write modified freq data

kpitch, kstretch, inumbins, iampin, iampout, ifreqin, ifreqout xin

; make sure we start with an empty table
iclear 	ftgen 0, 0, inumbins, 2, 0
	tablecopy iampout, iclear
	tablecopy ifreqout, iclear

; perform a do-while loop, cycling through the tables and shifting pitch
kcount = 0
loop:
kindex 	= kcount/kpitch

if (kindex < inumbins) then
kval 	table kindex, iampin
kamp 	table kcount, iampout
	tablew kval+kamp, kcount, iampout

kval 	table kindex, ifreqin
	tablew kval*kpitch, kcount, ifreqout
endif

kcount = kcount + 1
kpitch = kpitch * kstretch

if (kcount < inumbins) kgoto loop

endop
 
