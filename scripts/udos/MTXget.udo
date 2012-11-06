/*
MTXget - Get a value from an MTX* matrix

DESCRIPTION
Get a value from an MTX* matrix

SYNTAX
ival MTXget imtxnum, ix [, iy, iz]

INITIALIZATION
ival - Value returned by the matrix
imtxnum - ftable number of the MTX* matrix to be read
ix - Position in the first dimension of the table 
iy - (optional, default = 0) Position in the second dimension of the table 
iz - (optional, default = 0) Position in the third dimension of the table 
The value ival is read from position ix, iy, iz of table imtxnum at init-time. If the table has two dimensions, do not give any value to iz. 
Please note that there are currently no bound checks, so your position values must be valid, otherwise errors may occur. 
Please note that the first position in any dimension has a value of 0.

CREDITS
Andres Cabrera
*/

	opcode MTXget,i,iioo

imtxnum, ix, iy, iz xin
isizex tablei 0, imtxnum
isizey tablei 1, imtxnum
isizez tablei 2, imtxnum
ipos = (iz*isizex*isizey) + (iy*isizex) + ix + 3
ivalue tablei ipos, imtxnum
xout ivalue

	endop
 
