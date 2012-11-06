/*
TbToLin - Reads a table in the same way as a linseg opcode

DESCRIPTION
Reads a table which contains segments of value - duration - value in the same way as a linseg opcocde would do.

SYNTAX
kLin TabToLin iFt

INITIALIZATION
iFt - a function table, usually generated with GEN02 and not normaized

PERFORMANCE
kLin - k-rate output

CREDITS
joachim heintz 2012
*/

  opcode TbToLin, k, i
ift        xin
iftlen     tableng    ift
indx1      =          0
indx2      =          1
indx3      =          2
segment:
if indx3 >= iftlen igoto end
iStart     table      indx1, ift
iDur       table      indx2, ift
iTarget    table      indx3, ift
           timout     0, iDur, do
           reinit     segment
do:
kOut       linseg     iStart, iDur, iTarget
indx1      =          indx1+2
indx2      =          indx2+2
indx3      =          indx3+2
end:
           xout       kOut
  endop
 
