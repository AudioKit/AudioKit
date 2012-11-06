/*
StraySetEl - Inserts an element in an array-string at a certain position

DESCRIPTION
Puts the string Sin at the position ielindx (default=-1: at the end) of Stray, and returns the result as a string. Elements in the string are seperated by the two ascii-coded seperators isepA (default=32: space) and isepB (default=9: tab). If just isepA is given, it is also read as isepB. The new element is inserted using the seperator isepOut (default=isep1)
Requires Csound 5.16 or higher (new parser)

SYNTAX
Sres StraySetEl Stray, Sin [, ielindx [, isep1 [, isep2 [,isepOut]]]]

INITIALIZATION
Stray - a string as array 
Sin - a string to be inserted 
ielindx - the element position in Stray at which the new element is to be inserted (starting with 0); the default -1 means append at the end of Stray
isep1 - the first seperator (default=32: space)
isep2 - the second seperator (default=9: tab) 
isepOut - the seperator for the insertion (default=isep1)

CREDITS
joachim heintz april 2010 / feb 2012
*/

  opcode StraySetEl, S, SSjjjj
Stray, Sin, ielindx, isepA, isepB, isepOut xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
isepOut   =         (isepOut == -1 ? isep1 : isepOut)
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
SepOut    sprintf   "%c", isepOut
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
iel       =         0; actual element position
iwarsep   =         1
indx      =         0
;;APPEND Sin IF ielindx=-1
 if ielindx == -1 then
Sres      sprintf   "%s%s%s", Stray, SepOut, Sin
          igoto     end	
 endif
;;PREPEND Sin IF ielindx=0
 if ielindx == 0 then
Sres      sprintf   "%s%s%s", Sin, SepOut, Stray
          igoto     end	
  endif
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
;;NEXT SIGN IS NOT SEP1 NOR SEP2
if isep1p != 0 && isep2p != 0 then
 if iwarsep == 1 then; first character after a seperator 
  if iel == ielindx then; if searched element index
S1        strsub    Stray, 0, indx; string before Sin
S2        strsub    Stray, indx, -1; string after Sin
Sres      sprintf   "%s%s%s%s", S1, Sin, SepOut, S2
          igoto     end
  else 			;if not searched element index
iel       =         iel+1; increase it
iwarsep   =         0; log that it's not a seperator 
  endif 
 endif 
;;NEXT SIGN IS SEP1 OR SEP2
else 
iwarsep   =         1
endif
          loop_lt   indx, 1, ilen, loop 
;;APPEND Sin IF ielindx is >= number of elements
Sres      sprintf   "%s%s%s", Stray, SepOut, Sin
end:      xout      Sres
  endop 
 
