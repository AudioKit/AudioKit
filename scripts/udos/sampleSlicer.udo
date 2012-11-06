/*
sampleSlicer - Reads a function table in incremental slices.

DESCRIPTION
Reads a function table in incremental slices.  Frequency is independent.
Uses lposcil, allowing GEN01 function tables with zero size.

SYNTAX
asig sampleSlicer kamp, kfreq, kminslice, kmaxslice, kmininc, kmaxinc, ifn

INITIALIZATION
ifn -- the function table containing sample to be sliced.  can be zero size.

PERFORMANCE
kamp -- amplitude
kfreq -- .5 = half speed, 2 = double speed... same as lposcil
kminslice/kmaxslice -- minimum/maximum length of slice in seconds
kmininc/kmaxinc -- minimum/maximum length of increment per slice in seconds

CREDITS
credits
*/

	opcode sampleSlicer, a, kkkkkki
kamp, kfreq, kminslice, kmaxslice, kmininc, kmaxinc, ifn xin
isize = ftlen(ifn)
kphase init 0
kslice random kminslice, kmaxslice
kinc random kmininc, kmaxinc

redo:
timout 0, i(kslice), continue
kphase = (kphase < (isize - i(kslice) * sr)?kphase + kinc * sr:0)
reinit redo

continue:
aenv linseg 0, .01, 1, i(kslice) - .02, 1, .01, 0
asig lposcil3 kamp, kfreq, 0, 0, ifn, i(kphase)
rireturn
asig = asig * aenv
xout asig
	endop
 
