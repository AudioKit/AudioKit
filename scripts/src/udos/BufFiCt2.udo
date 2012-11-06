/*
BufFiCt2 - creates two gen01 function table from a stereo soundfile

DESCRIPTION
Creates two gen01 function table from a stereo soundfile. This is nothing else than a simplification of creating the same with a ftgen statement.
Use BufFiCtNd to create a non-deferred function table from a soundfile


SYNTAX
iftL, iftR BufFiCt2 Sfilenam [, ifnL [, ifnR [, inorm]]]

INITIALIZATION
Sfilenam - file name or path as string
ifnL, ifnR - if zero (which is also the default), the number of the function table is given by Csound. Any other positive integer will represent the function table, but the user must take care of not using a number twice
inorm - if zero, the table is not normalized. This is also the default, while any other number creates a normalized table
iftL, iftR - output table numbers for left and right channel

CREDITS
joachim heintz 2010
*/

  opcode BufFiCt2, ii, Sooo
Sfilenam, ifnL, ifnR, inorm xin
igen      =         (inorm == 0 ? -1 : 1)
iftL      ftgen     ifnL, 0, 0, igen, Sfilenam, 0, 0, 1
iftR      ftgen     ifnR, 0, 0, igen, Sfilenam, 0, 0, 2
          xout      iftL, iftR  
  endop

 
