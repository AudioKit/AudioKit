/*
TbPrmRndk - Permutes the values of a function table randomly, at k-time

DESCRIPTION
Permutes the values of ift randomly and overwrites this table with the result. This operation is performed once a k-cycle, as long as a trigger is positive. See TbPrmRnd for the i-rate version

SYNTAX
TbPrmRndk ift, ktrig

INITIALIZATION
ift - function table to be permuted

PERFORMANCE
ktrig - if > 0, the permutation is performed once a k-cycle

CREDITS
joachim heintz 2012
*/

  opcode TbPrmRndk, 0, ik
;changes the contents of ift each time ktrig is positive
ift, ktrig xin
itablen    =          ftlen(ift)
icopy      ftgentmp   0, 0, -itablen, -2, 0
if ktrig > 0 then
           tablecopy  icopy, ift
kleng      =          itablen
kndxerg    =          0
loop:
krand      random     0, kleng - .0001
kndex      =          int(krand)
kval       tab        kndex, icopy
           tabw       kval, kndxerg, ift
lshift:
if (kndex == kleng-1) kgoto next
kndxneu    =          kndex
kndxalt    =          kndxneu+1
kvalalt    tab        kndxalt, icopy
           tabw       kvalalt, kndxneu, icopy
kndex      =          kndex + 1
           kgoto      lshift
next:
kleng      =          kleng - 1
kndxerg    =          kndxerg + 1
if (kleng > 0) kgoto loop
endif
  endop
 
