/*
GutoPitchTracker - Returns amplitude and cycles per second of the most prominent complex tone in the spectrum of arbitrary audio input.

DESCRIPTION
Returns amplitude and cycles per second of the most prominent complex tone in the spectrum of arbitrary audio input signal.

Internally, this opcode makes use of the rarely used w-sig via the specptrk opcode.

See also:

http://csounds.com/manual/html/spectrum
http://csounds.com/manual/html/specptrk

SYNTAX
kcps, kamp  GutoPitchTracker  ain

PERFORMANCE
kcps  --  Cycles per second converted from octave class notation.

kamp  --  Decimal octave and summed dB representation of amplitude.

ain  --  Audio signal input. This can be realtime, soundfile, or from one of Csound's many unit generators. Any valid audio signal can be passed as input here.

CREDITS
Original implementation by Guto Caminhoto, 03/2000. UDO-ization and examples by David Akbari, 05/2006. Special thanks to Victor Lazzarini for the Vocoder UDO.
*/

	opcode	GutoPitchTracker,	kk, a

/*
Guto Caminhoto
guto@sercomtel.com.br
http://members.tripod.com/Guto001/index.html
Guto 03/2000
-- UDOization and examples by David Akbari - May 2006
*/

ain    xin
ain    dcblock   ain	; adjust DC
 
iocts   =	8
iprd    =	0.002
ifrqs   =	24
iq      =	32
ihann   =	0
idbout  =	3
idsprd  =	0
idsines =	0

wsig     spectrum	ain,	iprd, iocts, ifrqs , iq, ihann, idbout, idsprd, idsines
krms     rms		ain, 20      ; find a monaural rms value
kvar     =  0.6 + krms/8000      	 ; & use to gate the pitch variance

ilo      =	7.0
ihi      =	10.0
istrt    =	8.0
idbthres =	10
inptls   =	4
irolof   =	0.75
iodd     =	1
iconf    =	12
intrp    =	1
ifprd    =	0
iwtflg   =	0
 
koct, kamp  specptrk  wsig, kvar, ilo, ihi, istrt, idbthres, inptls, irolof, iodd, iconf, intrp, ifprd,iwtflg

kcps  = cpsoct(koct)	; convert

	xout	kcps, kamp

		endop

 
