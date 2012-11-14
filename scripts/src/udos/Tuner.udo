/*
Tuner - Tunes a given fundamental to a user-provided  scale

DESCRIPTION
Tuner picks a fundamental frequency and adjusts it to fit a given 7-note scale. The scale is to be given in pitch classes on a function table. For instance:

f1 0 8 2 0 2 4 5 7 9 11 12

defines a major scale (in C). The last note of the scale is ignored. 

SYNTAX
kfout Tuner kfr,ksm,kfn,ktrans

PERFORMANCE
kfr - input frequency (in Hz)
ksm - smoothing time (in secs)
kfn - function table containing the scale to be fitted to
ktrans - scale transposition in semitones

kfout - adjusted freq in Hz

CREDITS
original idea by Brian Carty, with modifications by V Lazzarini
*/

opcode Tuner, k, kkkk

kfr,ksm,kfn,ktrans  xin

if (kfr > 10) kgoto ok
kfr = 440
ok: 
knot = pchoct(octcps(kfr))
ktmp = frac(knot)*100
koct = int(knot)
kpch = int(ktmp)

kpos init 0
test:
knote tablekt kpos, kfn     ; get a pitch class
knote = (knote+ktrans)%12
if kpch == knote kgoto next ; test match
kpos = kpos + 1           ; increment table pos
if kpos >= 7  kgoto shift ; shift by a semitone
kgoto test                ; loop back

shift:
if (ktmp >= kpch) kgoto plus
kpch = kpch - 1
kgoto next
plus:
kpch = kpch + 1

next:
kpos = 0

ktarget = cpspch(koct+kpch/100)
kratio = ktarget/kfr
kratioport portk kratio,ksm 
       xout  kratioport     
endop
 
