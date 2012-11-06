/*
TbToSF - writes the content of a table to a soundfile

DESCRIPTION
writes the content of a table to a soundfile, with optional start and end point

SYNTAX
TbToSF ift, Soutname, ktrig [,iformat [,istart [,iend]]]

INITIALIZATION
ift - function table to write
Soutname - output file name in double quotes
iformat - output file format according to the fout manual page. if not specified or -1, the file is written with a wav header and 24 bit
istart - start in seconds in the function table to write (default=0)
iend - last point to write in the function table in seconds (default=-1: until the end)

PERFORMANCE
ktrig - if 1, the file is being written in one control-cycle. Make sure the trigger is 1 just for one k-cycle; otherwise the writing operation will be repeated again and again in each control cycle

CREDITS
joachim heintz july 2010
*/

  opcode TbToSF, 0, iSkjoj
ift, Soutname, ktrig, iformat, istart, iend xin; start (default = 0) and end (default = last sample) in seconds
istrtsmps =         istart*sr; start to write in samples 
iendsmps  =         (iend == -1 ? ftlen(ift) : iend*sr); end to write in samples
 if iformat == -1 then
iformat   =         18; default: wav 24 bit (for other options see fout manual page)
 endif
 if ktrig == 1 then; make sure that trigger sends "1" just for one k-cycle
kcnt      init      istrtsmps; set the counter to 0 at start
loop:
kcnt      =         kcnt+ksmps; next value (e.g. 10 if ksmps=10)
andx      interp    kcnt-1; build audio index (e.g. from 0 to 9)
asig      tab       andx, ift; read the table values as audio signal
          fout      Soutname, iformat, asig; write asig to a file
 if kcnt <= iendsmps-ksmps kgoto loop; go back as long there is something to do
 endif 
  endop
 
