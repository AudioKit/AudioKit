/*
StraySub - Returns a subset of elements in an array-string

DESCRIPTION
Returns a subset of elements in Stray, from istart (included) to iend (excluded). The defaults are istart=0 (first element) and iend=-1 (end of string). Elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). If just one seperator is used, isep2 equals isep1.
The resulting substring will use isepOut as seperator (default=isep1)
Requires Csound 5.16 or higher (new parser)

SYNTAX
Sub StraySub Stray [, istart [, iend [, isepA [, isepB [, isepOut]]]]]

INITIALIZATION
Stray - a string as array
istart - first element to extract (default=0)
iend - first element after selection (default=-1: end of string)
isep1 - first seperator for the elements in Stray (default=32: space)
isep2 - second seperator for the elements in Stray (default=9: tab) 
isepOut - seperator for the elements in the output string (default=isep1)
Sub - resulting subset of Stray

CREDITS
joachim heintz january 2012
*/

  opcode StraySub, S, Sojjjj
Stray, istart, iend, isepA, isepB, isepOut xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
isepOut   =         (isepOut == -1 ? isep1 : isepOut)
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
Sres      =         ""
ilen      strlen    Stray
iend      =         (iend == -1 ? ilen : iend) ;for simplifying tests later
istartsel =         -1; startindex for any element
iel       =         -1; actual number of element while searching
iwarleer  =         1; is this the start of a new element
indx      =         0 ;character index
inewel    =         0 ;new element to find
;;LOOP
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Schar     strsub    Stray, indx, indx+1; this character
isep1p    strcmp    Schar, Sep1; returns 0 if Schar is sep1
isep2p    strcmp    Schar, Sep2; 0 if Schar is sep2
is_sep    =         (isep1p == 0 || isep2p == 0 ? 1 : 0) ;1 if Schar is a seperator
 ;END OF STRING AND NO SEPARATORS BEFORE?
 if indx == ilen && iwarleer == 0 then
Sel       strsub    Stray, istartsel, -1
inewel    =         1
 ;FIRST CHARACTER OF AN ELEMENT?
 elseif is_sep == 0 && iwarleer == 1 then
istartsel =         indx ;if so, set startindex
iwarleer  =         0 ;reset info about previous separator 
iel       =         iel+1 ;increment element count
 ;FIRST SEPERATOR AFTER AN ELEMENT?
 elseif iwarleer == 0 && is_sep == 1 then
Sel       strsub    Stray, istartsel, indx ;get elment
inewel    =         1 ;tell about
iwarleer  =         1 ;reset info about previous separator
 endif
 ;APPEND THE ELEMENT TO THE RESULT IF IN RANGE
 if inewel == 1 && iel >= istart && iel < iend then ;for each new element in range
Selsep    sprintf   "%c%s", isepOut, Sel ;prepend seperator
Sres      strcat    Sres, Selsep ;append to result
 endif
inewel    =         0
          loop_le   indx, 1, ilen, loop 
end:
Sout      strsub    Sres, 1; remove starting seperator
          xout      Sout
  endop 
 
