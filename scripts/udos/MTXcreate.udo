/*
MTXcreate - Creates a matrix for use with the other MTX* UDOs

DESCRIPTION
This UDO creates a new matrix, or a matrix from an existant ftable, with up to 3 dimensions, for use with other MTX* UDOs, like MTXget or MTXset.

SYNTAX
imtxnum MTXcreate ix [,iy, iz, idefault, iftnum]

INITIALIZATION
imtxnum- Ftable containing the matrix
ix - Number of elements in the x dimension
iy - (optional, default = 0) Number of elements in the y dimension
iz - (optional, default = 0) Number of elements in the z dimension
idefault - (optional, default = 0) A scalar to fill a newly created table with.
iftnum - (optional, default = 0) Number of ftable to convert to matrix.

PERFORMANCE
MTXcreate creates a new matrix if iftnum is 0. If iftnum is given, MTXcreate will convert the table into a matrix usable by other MTX* opcodes. The dimensions of the table are determined by ix, iy and iz. If you want a two-dimensional table, do not specify iz or use a value of 0.
Please note that if an existing table is converted using MTXcreate, the table will be modified.
MTXinit must have been called (and defined in the orchestra) before MTXcreate.

CREDITS
Andres Cabrera
*/

	opcode MTXcreate,i,ioooo

ix, iy, iz, idefault, iftnum xin

giMTXUDOnum = giMTXUDOnum +1
if (iftnum==0) then
iftnum = giMTXUDOnum + giMTXUDOtabnumoffset
isize = powoftwo(int(logbtwo((ix*iy*iz)+3))+1)
ifno ftgen iftnum, 0, isize, -16, idefault, isize-1, idefault
else
vcopy_i iftnum,iftnum, (ix*iy*iz), 3, 0
endif
tableiw ix, 0, iftnum
tableiw iy, 1, iftnum
tableiw iz, 2, iftnum
xout iftnum

	endop
 
