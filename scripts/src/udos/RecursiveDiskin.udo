/*
RecursiveDiskin - Alters kpitch and iskiptime each time it calls itself to create a little bit of texture.

DESCRIPTION
Alters kpitch and iskiptime each time it calls itself to create a little bit of texture.

SYNTAX
aout    RecursiveDiskin ifile, kpitch, iskiptime, iwrap, iformat, inum, icnt

CREDITS
Author: Jim Hearon
*/

	opcode RecursiveDiskin, a, ikiiiip

ifile, kpitch, iskiptime, iwrap, iformat, inum, icnt      xin

if (icnt > inum) goto skip1

;ar1 [,ar2] [, ar3] [, ar4] diskin ifilcod, kpitch [, iskiptim]
;    [,iwraparound] [, iformat]

ar1 	diskin ifile, kpitch, iskiptime, iwrap, iformat
ar1 	= ar1 * .2 ; scale amplitude for recrusive calls
 
a1 	RecursiveDiskin ifile, kpitch + .3, iskiptime + .2, iwrap, iformat, inum, 

icnt + 1

skip1:

xout ar1 + a1
	
	endop
 
