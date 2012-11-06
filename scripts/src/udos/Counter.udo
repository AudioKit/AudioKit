/*
Counter - Step counter

DESCRIPTION
Counts steps upwards or downwards, whenever a trigger signal has been received. This is meant to be used in live interaction, and is simliar to counter objects in realtime programs like Max or Pd. The example shows how the basic function can be extended to repeat sequences in a certain range.

SYNTAX
kcount Counter kup, kdown [, istep [, istart]]

INITIALIZATION
istep - step size (default = 1)
istart - starting value (default = 0)

PERFORMANCE
kup - counts upwards when 1
kdown - counts downwards when 1
kcount - current count as output

CREDITS
joachim heintz 2011
*/

  opcode Counter, k, kkio
kup, kdown, istep, istart xin
kcount    init      istart
kchange   changed   kup, kdown
if kchange == 1 then
 if kup == 1 then
kcount    =         kcount+istep
 elseif kdown == 1 then	
kcount    =         kcount-istep
 endif
endif
          xout      kcount
  endop
 
