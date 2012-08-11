Csound Haiku - IV
Iain McCurdy, 2011.

<CsoundSynthesizer>

<CsOptions>
-odac -dm0 -+rtmidi=null -+rtaudio=null -+msg_color=0
</CsOptions>

<CsInstruments>
sr 		= 		44100
ksmps 		= 		32
nchnls 		= 		2
0dbfs 		= 		1

gisine		ftgen		0, 0, 4096, 10, 1
gioctfn		ftgen		0, 0, 4096, -19, 1, 0.5, 270, 0.5
gasendL		init		0
gasendR		init		0
ginotes		ftgen		0, 0, -100, -17, 0, 8.00, 10, 8.03, 15, 8.04, 25, 8.05, 50, 8.07, 60, 8.08, 73, 8.09, 82, 8.11
		seed		0
;		alwayson	"trigger_notes"
;		alwayson	"reverb"

		instr		trigger_notes
krate		rspline		0.04, 0.15, 0.05, 0.1
ktrig		metro		krate
gktrans		init		0
gktrans		trandom		ktrig,-1, 1
gktrans		=		semitone(gktrans)
idur		=		15
		schedkwhen	ktrig, 0, 0, "hboscil_note", rnd(2), idur
		schedkwhen	ktrig, 0, 0, "hboscil_note", rnd(2), idur
		schedkwhen	ktrig, 0, 0, "hboscil_note", rnd(2), idur
		schedkwhen	ktrig, 0, 0, "hboscil_note", rnd(2), idur
		endin

		instr		hboscil_note
ipch		table		int(rnd(100)),ginotes
icps		=		cpspch(ipch)*i(gktrans)*semitone(rnd(0.5)-0.25)
kamp		expseg		0.001,0.02,0.2,p3-0.01,0.001
ktonemoddep	jspline		0.01,0.05,0.2
ktonemodrte	jspline		6,0.1,0.2
ktone		oscil		ktonemoddep,ktonemodrte,gisine
kbrite		rspline		-2,3,0.0002,3
ibasfreq	init		icps
ioctcnt		init		2
iphs		init		0
a1 		hsboscil 	kamp, ktone, kbrite, ibasfreq, gisine, gioctfn, ioctcnt, iphs	
amod		oscil		1, ibasfreq*3.47, gisine
arm		=		a1*amod
kmix		expseg		0.001, 0.01, rnd(1), rnd(3)+0.3, 0.001
a1		ntrpol		a1, arm, kmix
a1 		pareq 		a1/10, 400, 15, .707
a1		tone		a1, 500
kpanrte		jspline		5, 0.05, 0.1
kpandep		jspline		0.9, 0.2, 0.4
kpan		oscil		kpandep, kpanrte, gisine
a1,a2		pan2		a1, kpan
a1		delay		a1, rnd(0.1)
a2		delay		a2, rnd(0.1)
kenv		linsegr		1, 1, 0
a1		=		a1*kenv
a2		=		a2*kenv
		outs		a1, a2
gasendL		=		gasendL+a1/5
gasendR		=		gasendR+a2/5
		endin

		instr		reverb
aL, aR		reverbsc	gasendL, gasendR, 0.9, 10000
		outs		aL, aR
		clear		gasendL, gasendR
		endin

</CsInstruments>

<CsScore>
f 0 3600
i "trigger_notes" 0 3600
i "reverb" 0 3600


e
</CsScore>

</CsoundSynthesizer>