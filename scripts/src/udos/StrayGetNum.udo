/*
StrayGetNum - Gets one number from a string-array

DESCRIPTION
Returns the element with the position ielindex (starting from 0) in Stray. This element must be a number (the other elements can be strings or charcters). By default, the seperators between the elements are spaces and tabs. Others seperators can be defined by their ASCII code number.
If ielindx is out of range, or if the element is not a number, an error occurs

SYNTAX
inum StrayGetNum Stray, ielindx [, isep1 [, isep2]]

INITIALIZATION
Input:
Stray - a string as array
ielindx - the index of the element (starting with 0)
isep1 - the first seperator (default=32: space)
isep2 - the second seperator (default=9: tab)
If the defaults are not used and just isep1 is given, it's the only seperator. If you want two seperators (as in the dafault), you must give isep1 and isep2
Output:
inum - the number which is at the ielindx position of Stray


CREDITS
joachim heintz april 2010
*/

  opcode StrayGetNum, i, Sijj
;returns ielindex in Stray. this element must be a number
Stray, ielindx, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
istartsel =         -1; startindex for searched element
iendsel   =         -1; endindex for searched element
iel       =         0; actual number of element while searching
iwarleer  =         1
indx      =         0
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
;;NEXT SIGN IS NOT SEP1 NOR SEP2
if isep1p != 0 && isep2p != 0 then
 if iwarleer == 1 then; first character after a seperator 
  if iel == ielindx then; if searched element index
istartsel =         indx; set it
iwarleer  =         0
  else 			;if not searched element index
iel       =         iel+1; increase it
iwarleer  =         0; log that it's not a seperator 
  endif 
 endif 
;;NEXT SIGN IS SEP1 OR SEP2
else 
 if istartsel > -1 then; if this is first selector after searched element
iendsel   =         indx; set iendsel
          igoto     end ;break
 else	
iwarleer  =         1
 endif 
endif
          loop_lt   indx, 1, ilen, loop 
end: 		
Snum      strsub    Stray, istartsel, iendsel
inum      strtod    Snum
          xout      inum
  endop 
 
