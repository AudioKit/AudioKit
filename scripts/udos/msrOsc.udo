/*
msrOsc - Simple Generator

DESCRIPTION
Generators simplified. De-clicked envelopes.

SYNTAX
aout  msrosc iamp, ifreq, ifn

INITIALIZATION
include the UDO in your instrument 0 space. Several F tables are created and used to make noises.

the Half wave functions have a range of 0 to 1.
all other functions have a range of -1 to 1

iamp -- Amplitude, must be greater than zero. If out of range it is set to zero.

ifreq -- Frequcency. If 20 or less, is assumed to need convertion
	 from pitch to Hz

ifn   -- 1 Sine
	 2 Triangle
	 3 Saw
	 4 Square
	 5 Tube Distortion
	 6 Half Triangle
	 7 Half Square
	 8 Half Saw
	 9 White Noise


PERFORMANCE
Generates indicated wave with amplitude declick ramps of .02 sec on each end. In the
case of White Noise, frequency has no meaning.

Note that I prepended my initials, msr on this code for easy use. Please rename it and morph it to suit your own ideas.
send ideas, additions and comments on the csound@lists.bath.ac.uk news group.

CREDITS
Michael Rempel Author, freely pagerized from many sources.
*/

;Sine 
gimsrsin	ftgen 0, 0, 8193, 10, 1

;Triangle 
gimsrtri	ftgen 0, 0, 8193, 7, -1, 4096,1,4096,-1

;Square
gimsrsqr	ftgen 0, 0, 8193, 7, 1,  4096, 1, 0, -1, 4096, -1

;Saw
gimsrsaw	ftgen 0,0, 8193, 7, -1, 8192,1

;Tube Distortion from Hans Mikelson\\\'s multi-effects
gimsrtub        	ftgen 0, 0,  8193, 7, -.8, 934, -.79, 934, -.77, 934, -.64, 1034, -.48, 520, .47, 2300, .48, 1536, .48 

;Half Triangle
gimsrhtr	ftgen 0, 0, 8193, 7, 0, 4096,1,4096,0

;Half Square	
gimsrhsq	ftgen 0, 0, 8193, 7, 1,  4096, 1, 0, 0, 4096, 0

;Half Saw
gimsrhsw	ftgen 0, 0, 8193, 7, 0, 8192,1

; Noise
gimsrnse        	ftgen 0, 0, 8193, 21, 1

        opcode  msrosc, a,iii
iamp, ifreq, ifn xin
ifunc	= ifn
	if ifn >=1 igoto ifnok1
	ifunc = 1
ifnok1:
	if ifn < 10 igoto ifnok2
	ifunc = 1
ifnok2:
ifr	= ifreq
	if ifreq > 20 igoto freqok
		ifr = cpspch(ifreq)
freqok:
idur	= p3-.04
	if idur < 0 igoto durok
		idur = 0
durok:
iam	= iamp
	if iamp >= 0 igoto ampok
		iam = 0
ampok:

idur	= p3-.04

kamp      linseg    0, .02, 1, idur, 1, .02, 0                ; Declick
; Figure out asin depending on the oscilator type.
; the conditional structure is fairly efficient, testing max 3 conditions.
	if ifunc >4 goto tube
	if ifunc > 2 goto square
	if ifunc > 1 goto triangle  
;1
sine:
asin    oscil	iam, ifr, gimsrsin

	goto done

;2
triangle:
asin	oscil	iam, ifr, gimsrtri
	goto done
;3
square:
	if ifunc > 3 goto saw
asin	oscil	iam, ifr, gimsrsqr
	goto done
;4
saw:
	; no test	
asin	oscil	iam, ifr, gimsrsaw
	goto done
;5
tube:
	if ifunc > 7 goto hsaw
	if ifunc > 5 goto htriangle
asin	oscil	iam, ifr, gimsrtub
	goto done
;6
htriangle:
	if ifunc > 6 goto hsquare
asin	oscil	iam, ifr, gimsrhtr
	goto done
;7
hsquare:
asin	oscil	iam, ifr, gimsrhsq
	goto done
;8
hsaw:
	if ifunc > 8 goto noise
asin	oscil	iam, ifr, gimsrhsw
	goto done
;9
noise:
a2      oscil           iam,ifr,gimsrnse
asin      =( a2*2)-p4

done:
        xout      asin*kamp
        endop


 
