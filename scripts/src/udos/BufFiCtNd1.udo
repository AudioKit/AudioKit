/*
BufFiCtNd1 - creates a non deferred function table from a mono soundfile and returns its length

DESCRIPTION
Creates a non deferred function table from a mono soundfile and returns its length. This can be useful is you want to use opcodes (for instance table3) which do not work with deferred size function tables

SYNTAX
ift, ilen BufFiCtNd1 Sfilenam [, ichn [, iftnum [, inorm]]]

INITIALIZATION
Sfilenam - file name or path as string
ichn - channel in Sfilenam to read (default=1)
iftnum - if zero (which is also the default), the number of the function table is given by Csound. Any other positive integer will represent the function table, but the user must take care of not using a number twice 
inorm - if zero, the table is not normalized. This is also the default, while any other number creates a normalized table
ift - output table number
ilen - length of the function table created (which is also the length of the soundfile in samples)

CREDITS
joachim heintz 2010
*/

  opcode BufFiCtNd1, ii, Spoo
Sfilenam, ichn, iftnum, inorm xin
igen      =         (inorm == 0 ? -1 : 1)
ifttmp    ftgen     0, 0, 0, igen, Sfilenam, 0, 0, ichn
ilen      tableng   ifttmp
ift       ftgen     iftnum, 0, -ilen, -2, 0
          vcopy_i   ift, ifttmp, ilen
          ftfree    ifttmp, 0
          xout      ift, ilen
  endop
 
