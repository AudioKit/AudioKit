/*
stereoGrain - Granular synthesis similar to granule but in stereo with control rate parameters and unlimited transpositions.

DESCRIPTION
Granular synthesis similar to granule but in stereo with control rate parameters and unlimited transpositions.  Uses rnd31 with control of random distribution for frequency, pan, and amplitude.
GEN01 function tables with zero size are ok.

SYNTAX
al, ar stereoGrain kamp, kampoff, kgrain, kgrainoff, kgap, kgapoff, kmaxskip, kcenterpan, kampr, kfreqr, kpanr, katt, kdec, kpoint, knumfreq, ifreqfn, ifn, idens

INITIALIZATION
ifreqfn -- function table with frequencies.  for granulating samples, 1=no change, 2=one octave up, etc.
ifn -- function table to be granulated.  can be GEN01 with zero size.
idens -- number of voices/simultaneous grains.

PERFORMANCE
kamp -- amplitude
kgrain -- grain size in seconds
kgap -- gap size in seconds
kampoff/kgrainoff/kgapoff -- random offset, generally a value from 0-1, one being the largest offset.
kmaxskip -- maximum skip time from the grain pointer in seconds.
kcenterpan -- values from -1 (left) to 1 (right).  random pan centers around this value.
kampr, kfreqr, kpanr -- random distribution for amplitude, frequency, and pan -- see rnd31
katt, kdec -- attack and decay of grain in relation to grain size; i.e. katt=.1 means the attack is .1 * kgrain.  katt+kdec should not exceed 1.
kpoint -- the grain pointer.  similar to the pointer in fog, except that it refers to the samples in the function table and should be scaled to reflect this (so, a pointer that reads from the beginning to the end of a one-second sample with a 44100 sr should output values from 0-44100).  see linearPointer and boomerangPointer for examples of udo pointers.
knumfreq -- the number of frequencies to be read from ifreqfn

CREDITS
bhob rainey
*/

	opcode stereoGrain, aa, kkkkkkkkkkkkkkkiiip
kamp, kampoff, kgrain, kgrainoff, kgap, kgapoff, kmaxskip, kcenterpan, kampr, kfreqr, kpanr, katt, kdec, kpoint, knumfreq, ifreqfn, ifn, idens, icount xin

ainl init 0
ainr init 0

if (icount > idens) goto out

loop:
ainl, ainr stereoGrain kamp, kampoff, kgrain, kgrainoff, kgap, kgapoff, kmaxskip, kcenterpan, kampr, kfreqr, kpanr, katt, kdec, kpoint, knumfreq, ifreqfn, ifn, idens, icount + 1

out:
isamps = ftlen(ifn)
kdec limit kdec, .05, 1-katt
katt limit katt, .05, 1-kdec
kgrainmin = kgrain - kgrain * kgrainoff
kgrainmax = kgrain + kgrain * kgrainoff
kgapmin = kgap - kgap * kgapoff
kgapmax = kgap + kgap * kgapoff

redo:
ipan rnd31 1, i(kpanr)
ipan limit ipan + i(kcenterpan), -1, 1
ifreq rnd31 1, i(kfreqr)
ifreq = abs(ifreq * (i(knumfreq)-.001))
ifreq table ifreq, ifreqfn

iamp rnd31 i(kamp) * i(kampoff), i(kampr)
iamp = abs(iamp) + (i(kamp) - i(kamp) * i(kampoff))

igrain random i(kgrainmin), i(kgrainmax)
igap random i(kgapmin), i(kgapmax)
iskip random 0, i(kmaxskip)
iskip = iskip * sr
ipoint limit i(kpoint) + iskip, 0, isamps-(((igrain + igap) * sr) * ifreq)

timout 0, igrain + igap, continue
reinit redo

continue:
kl = sqrt(2)/2 * cos(ipan) - sin(ipan)
kri = sqrt(2)/2 * cos(ipan) + sin(ipan)
aline linseg 0, i(katt) * igrain, 1, (1-i(katt)-i(kdec)) * igrain, 1, i(kdec) * igrain, 0
asig lposcil3 iamp, ifreq, 0, isamps, ifn, ipoint
rireturn
asig = asig * aline
al = ainl + asig * kl
ar = ainr + asig * kri

xout al, ar
	endop
 
