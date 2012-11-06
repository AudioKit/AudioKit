/*
FilDirUp - Returns the directory above the current directory

DESCRIPTION
Returns the directory above the current directory


SYNTAX
SUpDir FilDirUp SCurDir

INITIALIZATION
SCurDir - current directory (with or without an ending slash)
SUpDir - directory above the current directory (returned without an ending slash)


CREDITS
joachim heintz 2012
*/

  opcode FilDirUp, S, S
SCurDir    xin
;make sure the input does not end with '/'
ilen       strlen     SCurDir
ipos       strrindex  SCurDir, "/"
 if ipos == ilen-1 then
Sok        strsub     SCurDir, 0, ipos
 else	
Sok        strcpy     SCurDir
 endif
ipos       strrindex  Sok, "/"
SUpDir     strsub     Sok, 0, ipos
           xout       SUpDir
  endop

 
