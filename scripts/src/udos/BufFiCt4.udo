/*
BufFiCt4 - creates fout gen01 function table from a four channel soundfile

DESCRIPTION
Creates four gen01 function table from a four channel soundfile. This is nothing else than a simplification of creating the same with a ftgen statement.
Use BufFiCtNd to create a non-deferred function table from a soundfile 

SYNTAX
ift1, ift2, ift3, ift4 BufFiCt4 Sfilenam [, ifn1 [, ifn2 [, ifn3 [, ifn4 [, inorm]]]]]

INITIALIZATION
Sfilenam - file name or path as string
ifn1 ... ifn4 - if zero (which is also the default), the number of the function table is given by Csound. Any other positive integer will represent the function table, but the user must take care of not using a number twice
inorm - if zero, the table is not normalized. This is also the default, while any other number creates a normalized table
ift1 ... ift4 - output table numbers

CREDITS
joachim heintz 2010
*/

  opcode BufFiCt4, iiii, Sooooo
Sfilenam, ifn1, ifn2, ifn3, ifn4, inorm xin ;filename, numbers of ftables (0=automatic(=default)), normalization (1=yes, 0=no(=default))
igen      =         (inorm == 0 ? -1 : 1)
ift1      ftgen     ifn1, 0, 0, igen, Sfilenam, 0, 0, 1
ift2      ftgen     ifn2, 0, 0, igen, Sfilenam, 0, 0, 2
ift3      ftgen     ifn3, 0, 0, igen, Sfilenam, 0, 0, 3
ift4      ftgen     ifn4, 0, 0, igen, Sfilenam, 0, 0, 4
          xout      ift1, ift2, ift3, ift4  
  endop

 
