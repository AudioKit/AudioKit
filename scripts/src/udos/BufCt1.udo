/*
BufCt1 - creates a function table of ilen seconds for recording

DESCRIPTION
creates an "empty" function table (filled with zeros) of ilen seconds, using GEN02, for recording sound

SYNTAX
ift BufCt1 ilen [, inum]

INITIALIZATION
ilen - length in seconds
inum - if zero (which is also the default), the number of the function table is given by Csound. Any other positive integer will represent the function table, but the user must take care of not using a number twice
ift - table number as output

CREDITS
joachim heintz 2010
*/

  opcode BufCt1, i, io
ilen, inum xin 
ift        ftgen     inum, 0, -(ilen*sr), 2, 0
           xout      ift
  endop

 
