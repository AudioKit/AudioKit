/*
TbDmpk - Prints a function table at k-time.

DESCRIPTION
Prints the content of a function table at k-time, whenever a trigger is positive. The indices being printed can be selected, the float precision and the number of values per line (up to 32).
You may have to set the flag -+max_str_len=10000 to avoid buffer overflow. See TbDmp for the i-time equivalent.
Requires Csound 5.18 or higher for the usage of the k-rate default values P, O and V (thanks to Victor Lazzarini for implementing this feature).

SYNTAX
TbDmpk ifn [,ktrig [,kstart [,kend [,kprec [,kppr]]]]]

INITIALIZATION
ifn - function table number

PERFORMANCE
ktrig - if > 0, ifn is printed once in each k-cycle (which is also the default). for any other value, no printing is performed
kstart - first index to be printed
kend - first index not to be printed. -1 means the end of the table
kprec - float precision while printing
kppr - parameters per row (maximum = 32)

CREDITS
joachim heintz 2012
*/

  opcode TbDmpk, 0, iPOVVO
ifn, ktrig, kstart, kend, kprec, kppr xin
kprint     init       0
if ktrig > 0 then
kppr       =          (kppr == 0 ? 10 : kppr)
kend       =          (kend == -1 || kend == .5 ? ftlen(ifn) : kend)
kprec      =          (kprec == -1 || kprec == .5 ? 3 : kprec)
kndx       =          kstart
Sformat    sprintfk   "%%.%df, ", kprec
Sdump      sprintfk   "%s", "["
loop:
kval       tab        kndx, ifn
Snew       sprintfk   Sformat, kval
Sdump      strcatk    Sdump, Snew
kmod       =          (kndx+1-kstart) % kppr
 if kmod == 0 && kndx != kend-1 then
           printf     "%s\n", kprint+1, Sdump
Sdump      strcpyk    ""
 endif
kprint     =          kprint + 1
           loop_lt    kndx, 1, kend, loop
klen       strlenk    Sdump
Slast      strsubk    Sdump, 0, klen-2
           printf     "%s]\n", kprint+1, Slast
endif
  endop
 
