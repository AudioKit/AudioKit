/*
TbRmDp - Removes duplicates from a function table

DESCRIPTION
Removes duplicates from a function table, copies the elements in a new table, and returns the end position (which can be used to build a table with just these elements).
Requires the UDO TbMem

SYNTAX
iend TbRmDp iftsrc, iftdst [, ioffset [, inumels]]

INITIALIZATION
iftsrc - source function table
iftdst - table (usually with the same length as iftsrc) for copying the non-duplicated elements of iftsrc
ioffset - index to start copying of elements in iftsrc
inumels - number of elements to investigate
iend - position after the last index which has been written in iftdest

CREDITS
joachim heintz 2012
*/

  opcode TbRmDp, i, iioj
iftsrc, iftdst, ioffset, inumels xin
;copy first element
ifirst    tab_i     ioffset, iftsrc
          tabw_i    ifirst, 0, iftdst
;calculate border in iftsrc
iftlen    tableng   iftsrc
ireadend  =         (inumels == -1 || ioffset+inumels > iftlen ? iftlen : inumels+ioffset)
;compare each element with all already written in iftdst
;and add to iftdst if not already there
ireadindx =         ioffset+1
iwritindx =         1
loop:
iel       tab_i     ireadindx, iftsrc
itest     TbMem     iel, iftdst, 0, iwritindx
 if itest == -1 then
          tabw_i    iel, iwritindx, iftdst
iwritindx =         iwritindx + 1
 endif
          loop_lt   ireadindx, 1, ireadend, loop
          xout      iwritindx
  endop
 
