/*
FilDir - Returns the directory in a given path

DESCRIPTION
Returns the directory part of a given file path string (=everything before the last slash), at i-rate (csound 5.15 or higher).


SYNTAX
Sdir FilDir Spath

INITIALIZATION
Spath - full path as string
Sdir - directory

CREDITS
joachim heintz 2012
*/

  opcode FilDir, S, S
Spath      xin
ipos      strrindex Spath, "/"
Sdir      strsub    Spath, 0, ipos
          xout      Sdir
  endop
 
