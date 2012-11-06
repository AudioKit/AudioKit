/*
BufCt2 - creates two function tables of ilen seconds for recording

DESCRIPTION
creates two "empty" function tables (filled with zeros) of ilen seconds, using GEN02, for recording stereo sound input

SYNTAX
iftL, iftR BufCt2 ilen [, inumL [, inumR]]

INITIALIZATION
ilen - length in seconds
inumL, inumR - if zero (which is also the default), the number of the function table is given by Csound. Any other positive integer will represent the function table, but the user must take care of not using a number twice
iftL, iftR - table numbers as output

CREDITS
joachim heintz 2010
*/

  opcode BufCt2, ii, ioo
ilen, inumL, inumR xin 
iftL       ftgen     inumL, 0, -(ilen*sr), 2, 0
iftR       ftgen     inumR, 0, -(ilen*sr), 2, 0
           xout      iftL, iftR
  endop
 
