/*
FilSuf - Returns the suffix of a filename or path, optional in lower case 

DESCRIPTION
Returns the suffix (extension) of a filename or a full path, optional in lower case.

SYNTAX
Suf FilSuf Spath [,ilow]

INITIALIZATION
Spath - full pathname (or filename) as string
ilow - return ensuring lower case (1) or return as in Spath (0 = default)

CREDITS
joachim heintz 2012
*/

  opcode FilSuf, S, So
Spath,ilow xin
ipos      strrindex Spath, "."
Suf       strsub    Spath, ipos+1
 if ilow != 0 then
Suf       strlower  Suf 
 endif
          xout      Suf
  endop
 
