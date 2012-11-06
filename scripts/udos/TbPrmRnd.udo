/*
TbPrmRnd - Permutes the values of a function table randomly, at i-time

DESCRIPTION
Permutes the values of ift randomly and overwrites this table with the result. See TbPrmRndk for the k-rate version

SYNTAX
TbPrmRnd ift

INITIALIZATION
ift: function table to be permuted

CREDITS
joachim heintz 2009 / 2012
*/

  opcode TbPrmRnd, 0, i
;permutes the elements of ift
ift xin
itablen    =          ftlen(ift)
icopy      ftgentmp   0, 0, -itablen, -2, 0
           tableicopy  icopy, ift
ileng      =          itablen
indxerg    =          0
loop:
irand      random     0, ileng - .0001
index      =          int(irand)
ival       tab_i      index, icopy
           tabw_i     ival, indxerg, ift
lshift:
if (index == ileng-1) igoto next
indxneu    =          index
indxalt    =          indxneu+1
ivalalt    tab_i      indxalt, icopy
           tabw_i     ivalalt, indxneu, icopy
index      =          index + 1
           igoto      lshift
next:
ileng      =          ileng - 1
indxerg    =          indxerg + 1
if (ileng > 0) igoto loop
  endop
 
