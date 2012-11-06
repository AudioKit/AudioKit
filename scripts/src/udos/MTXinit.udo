/*
MTXinit - Initializaes MTX (matrix) engine

DESCRIPTION
This UDO initializes a simple matrix engine. This UDO is designed to be used with other MTX* family UDOs like MTXcreate, MTXget and MTXset.

SYNTAX
idiscard MTXinit [iMTXftnumoffset]

INITIALIZATION
idiscard- Serves no purpose, always outputs 0
iMTXftnumoffset - (optional) Ftable number in which to start creating matrices (default = 200)
Matrices are created inside ftables using MTXcreate, and can be easily accessed using MTXget and MTXset

CREDITS
Andres Cabrera
*/

	opcode MTXinit,i,o

ioffset xin
ioffset = (ioffset == 0 ? 200: ioffset)
giMTXUDOtabnumoffset init ioffset
giMTXUDOnum init 0
xout 0

	endop
 
