/*
MTXdestroy - Destroys an ftable containing an MTX* matrix

DESCRIPTION
Destroys an ftable containing an MTX* matrix

SYNTAX
idiscard MTXdestroy imtxnum

INITIALIZATION
idiscard - Serves no purpose always outputs 0
imtxnum - Number of the ftable containing the matrix to be destroyed.
Please note the ftable will be destroyed and will generate errors if it is required by any opcode (no only MTX* UDOs).

CREDITS
Andres Cabrera
*/

	opcode MTXdestroy,i,i

imtxnum xin
ftfree imtxnum, 0
xout 0

	endop
 
