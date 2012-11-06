/*
StrNumP - tests whether a string is a numerical string

DESCRIPTION
tests whether a string is a numerical string ("1" or "1.23435" but not "1a"). returns 1 for "yes" and 0 for "no". if "yes", the string can be converted to a number by the opcode strtod

SYNTAX
itest StrNumP String

INITIALIZATION
String - any string
itest - 1 if String is a numerical string, 0 if not

CREDITS
joachim heintz 2010
*/

  opcode StrNumP, i, S
;tests whether String is numerical string (simple, no scientific notation) which can be converted via strtod ito a float (1 = yes, 0 = no)
Str       xin	
ip        =         1; start at yes and falsify
ilen      strlen    Str
 if ilen == 0 then
ip        =         0
          igoto     end 
 endif 
ifirst    strchar   Str, 0
 if ifirst == 45 then; a "-" is just allowed as first character
Str       strsub    Str, 1, -1
ilen      =         ilen-1
 endif
indx      =         0
inpnts    =         0; how many points have there been
loop:
iascii    strchar   Str, indx; 48-57
 if iascii < 48 || iascii > 57 then; if not 0-9
  if iascii == 46 && inpnts == 0 then; if not the first point
inpnts    =         1
  else 
ip        =         0
  endif 
 endif	
          loop_lt   indx, 1, ilen, loop 
end:	     xout      ip
  endop 
 
