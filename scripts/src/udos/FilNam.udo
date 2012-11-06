/*
FilNam - Returns the file name in a given path

DESCRIPTION
Returns the file name (= everything after the last slash) in a given path

SYNTAX
Snam FilNam Spath

INITIALIZATION
Spath - full path name as string
Snam - name part

CREDITS
joachim heintz 2012
*/

  opcode FilNam, S, S
Spath      xin
ipos      strrindex Spath, "/"
Snam      strsub    Spath, ipos+1
          xout      Snam
  endop
 
