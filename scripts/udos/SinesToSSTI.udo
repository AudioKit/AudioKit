/*
SinesToSSTI - returns a function table with one of the four standard waveforms, produced by the addition of harmonics

DESCRIPTION
produces the waveforms saw (iwf=1, which is also the default), square (iwf=2), triangle (3), impulse (4) by the addition of inparts sinusoides (default = 10) and returns the result in a function table of itabsiz length (must be a power-of-2 or a power-of-2 plus 1, the default is 1024 points) with number ifno (default = 0 which means the number is given automatically)

SYNTAX
iftout SinesToSSTI iwf [, inparts [, itabsiz [, ifno]]]

INITIALIZATION
iwf - 1 = saw (default), 2 = square, 3 = triangle, 4 = impulse
inparts - number of sinusoides (default = 10)
itabsiz - length of the resulting function table (must be a power-of-2 or a power-of-2 plus 1, the default is 1024 points)
ifno - number of the function table (default = 0 which means the number is given automatically)

CREDITS
joachim heintz 2010
*/

  opcode SinesToSSTI, i, pooo
iwf, inparts, itabsiz, ifno xin
inparts	=		(inparts == 0 ? 10 : inparts)
itabsiz	=		(itabsiz == 0 ? 1024 : itabsiz)
iftemp		ftgen		0, 0, -(inparts * 3), -2, 0;temp ftab for writing the str-pna-phas vals
indx		=		1
loop:
if iwf == 1 then ; saw = 1, -1/2, 1/3, -1/4, ... as strength of partials
		tabw_i		1/(indx % 2 == 0 ? -indx : indx), (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 2 then ; square = 1, 1/3, 1/5, ... for odd partials
		tabw_i		1/(indx*2-1), (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 3 then ; triangle = 1, -1/9, 1/25, -1/49, 1/81, ... for odd partials
ieven		=		indx % 2; 0 = even index, 1 = odd index
istr		=		(ieven == 0 ? -1/(indx*2-1)^2 : 1/(indx*2-1)^2); results in 1, -1/9, 1/25, ...
		tabw_i		istr, (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 4 then ; impulse = 1, 1, 1, ... for all partials
		tabw_i		1, (indx-1)*3, iftemp; writes strength of partial (always 1)
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
endif

		loop_le	indx, 1, inparts, loop

iftout	ftgen		ifno, 0, itabsiz, 34, iftemp, inparts, 1; write table with GEN34 
		ftfree		iftemp, 0; remove iftemp
		xout		iftout
  endop
 
