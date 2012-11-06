/*
PfieldsToTable - Transfers score parameter fields to a function table

DESCRIPTION
writes score parameter fields to a function table

SYNTAX
PfieldsToTable ift, istart, iend

INITIALIZATION
ift: function table in which the values are to be written
istart: first p-field to write
iend: last p-field to write

CREDITS
joachim heintz 2009
*/

opcode PfieldsToTable, 0, iii
;;writes score parameter fields to a function table
;ift: function table in which the values are to be written
;istart: first p-field to write
;iend: last p-field to write
ift, istart, iend xin
index		init		0
loop:
ival		=		p(istart)
		tabw_i		ival, index, ift
istart		=		istart + 1
index		=		index + 1
if istart <= iend igoto loop
endop
 
