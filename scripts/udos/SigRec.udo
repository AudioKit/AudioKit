/*
SigRec - A table-based signal recorder (looping sampler), with pitch control

DESCRIPTION
This opcode records an input signal into a table and then plays it back in a loop with pitch control.

SYNTAX
asig SigRec ain, kpitch, ktrig, ifn, idur, ifad

INITIALIZATION
ifn - function table to hold the recorded signal (must
be long enough to hold all the requested duration)
idur - recording duration in secs
ifad - crossfade in secs

PERFORMANCE
asig - output (looped playback)
ain - input signal
kpitch - loop playback pitch
ktrig - trigger signal, 1 or above starts recording;
below 1 stops loop playback (ready for another recording).



CREDITS
Victor Lazzarini, 2005
*/

opcode SigRec, a,akkiii

    setksmps 1

ap   init 0
kp   init 0

/* sig, pitch, trigger, ftable, dur, crossfd */
ain,kpit,ktr,ifn,ilen,ic xin 

icft = ic*sr  /* crossfade samples */
iend = ilen*sr /* end point */
icft1 = icft+iend /* plus end */
kt trigger ktr, 1, 0 /* trigger */
if kt > 0 then
ktrig = 1        /* rec ON */
kp = 0
endif

if ktrig > 0 then  /* recording block */
ap = kp
    if kp < iend then /* fill in the duration */
    tablew ain, ap, ifn 
    endif
    if kp >= iend then /* crossfade block */
      if kp < icft1 then
       kfd = (kp-iend)/icft       
       aout  table  ap-iend, ifn
       aout = aout*kfd
       tablew ain*(1-kfd)+aout, ap-iend, ifn
       else            /* rec OFF */
       ktrig = 0   
      endif 
   endif
kp = kp + 1
endif             /* end recording block */

if ktrig == 0 then  /* playback block    */
aout table kp, ifn  
kp = kp + kpit            
   if kp > iend then  /* modulus */
   kp = kp - iend
   elseif kp < 0 then
   kp = iend - 1
   endif          
endif              /* end playback block */

   xout aout 
endop

 
