/*
ftreverse - reverses an ftable's contents in place at k-rate

DESCRIPTION
reverses an ftable's contents in place at k-rate

SYNTAX
ftreverse itablenum

INITIALIZATION
itablenum - number of ftable to reverse

CREDITS
Steven Yi
*/

opcode ftreverse,0,i

itablenum xin

ilen = ftlen(itablenum)

kleft = 0
kright = ilen - 1

loopStart:

ktemp   table kright, itablenum
kval    table kleft, itablenum

tablew  ktemp, kleft, itablenum
tablew  kval, kright, itablenum

kleft = kleft + 1
kright = kright - 1

if (kleft < kright) goto loopStart

       endop
 
