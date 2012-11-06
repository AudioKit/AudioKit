/*
vowgen - fof-based vocal generator with morfable vowels

DESCRIPTION
Uses ftmorf to morf between the formant structures of different vowels.

SYNTAX
asig vowgen kfreq, kmorf, koct, imode

INITIALIZATION
imode- the set of formants used.  The formants used to create the vowels were taken
	directly from the formant appendix in the Csound manual.  if imode = 0, the vowels were
	taken from a bass voice.  The vowels will sound the same, but the timbre will be affected.
	imode = 0: bass
	imode = 1: tenor
	imode = 2: countertenor
	imode = 3: alto
	imode = 4: soprano

PERFORMANCE
When vowgen is called, function tables are created for each vowel's formant structure.  For this reason, it might not work to have multiple vowgens in the same instrument.  A safer way is to have multiple instances of an instrument.

Inputs: 
	kfund- the fundamental frequency of the note.  You should consider varying it with an oscil 
		to create vibrato for more realistic vocals.

	kmorf- the index of the vowel.  In order to make it possible (using ftmorf) to sweep from any 
		vowel to any other vowel, I created an index as such:
		
		0  1  2  3  4  5  6  7  8  9 10 11 12  
		a  e  i  a  o  u  e  o  i  u  a  o  a


		this way if you sweep from a kmorf of 8 to 7, you sweep from i to o ("yo")
		there may be an easier way to do this now, so if you feel motivated, please research
		new ways (possibly with the new vector-based opcodes?) to sweep through the vowels

	koct- the same as the koct in the fof opcode.  If koct increases from 0 to 1, every other fof is 
		not generated, creating the effect of the voice dropping an octave.

CREDITS
Isaac Wallis Author.  Thanks to the Csound5 developers whose new opcodes made this possible.
*/


opcode	vowgen,	a, kkki

kfund,kmorf,koct,imode xin

imorf	ftgentmp 0, 0, 16, 10, 1; must be 16 elements long because vowels are in tables of length 16
ifenv	ftgentmp 0, 0, 4096, 19, .5, .5, 270, .5
ivib	ftgentmp 0, 0, 4096, 10, 1
if imode == 0 igoto bass
if imode == 1 igoto tenor
if imode == 2 igoto countertenor
if imode == 3 igoto alto
if imode == 4 igoto soprano
bass:
ia	ftgentmp 0, 0, 16, -2, 600, 1040, 2250, 2450, 2750, 0,  -7,  -9,  -9, -20, 60, 70, 110, 120, 130
ie	ftgentmp 0, 0, 16, -2, 400, 1620, 2400, 2800, 3100, 0, -12,  -9, -12, -18, 40, 80, 100, 120, 120
ii	ftgentmp 0, 0, 16, -2, 350, 1700, 2700, 3700, 4950, 0, -20, -30, -22, -28, 60, 90, 100, 120, 120
io	ftgentmp 0, 0, 16, -2, 450, 800,  2830, 3500, 4950, 0, -11, -21, -20, -40, 40, 80, 100, 120, 120
iu	ftgentmp 0, 0, 16, -2, 325, 700,  2530, 3500, 4950, 0, -20, -32, -28, -36, 40, 80, 100, 120, 120
igoto ind
tenor:
ia	ftgentmp 0, 0, 16, -2, 650, 1080, 2650, 2900, 3250, 0,  -6,  -7,  -8, -22, 80, 90, 120, 130, 140	
ie	ftgentmp 0, 0, 16, -2, 400, 1700, 2600, 3200, 3580, 0, -14, -12, -14, -20, 70, 80, 100, 120, 120	
ii	ftgentmp 0, 0, 16, -2, 290, 1870, 2800, 3250, 3540, 0, -15, -18, -20, -30, 40, 90, 100, 120, 120	
io	ftgentmp 0, 0, 16, -2, 400,  800, 2600, 2800, 3000, 0, -10, -12, -12, -26, 70, 80, 100, 130, 135	
iu	ftgentmp 0, 0, 16, -2, 350,  600, 2700, 2900, 3300, 0, -20, -17, -14, -26, 40, 60, 100, 120, 120
igoto ind
countertenor:
ia	ftgentmp 990, 0, 16, -2, 660, 1120, 2750, 3000, 3350, 0,  -6, -23, -24, -38, 80, 90, 120, 130, 140	
ie	ftgentmp 991, 0, 16, -2, 440, 1800, 2700, 3000, 3300, 0, -14, -18, -20, -20, 70, 80, 100, 120, 120	
ii	ftgentmp 992, 0, 16, -2, 270, 1850, 2900, 3350, 3590, 0, -24, -24, -36, -36, 40, 90, 100, 120, 120	
io	ftgentmp 993, 0, 16, -2, 430,  820, 2700, 3000, 3300, 0, -10, -26, -22, -34, 40, 80, 100, 120, 120	
iu	ftgentmp 994, 0, 16, -2, 370,  630, 2750, 3000, 3400, 0, -20, -23, -30, -34, 40, 60, 100, 120, 120
igoto ind
alto:
ia	ftgentmp 0, 0, 16, -2, 800, 1150, 2800, 3500, 4950, 0,  -4, -20, -36, -60, 80,  90, 120, 130, 140
ie	ftgentmp 0, 0, 16, -2, 400, 1600, 2700, 3300, 4950, 0, -24, -30, -35, -60, 60,  80, 120, 150, 200
ii	ftgentmp 0, 0, 16, -2, 350, 1700, 2700, 3700, 4950, 0, -20, -30, -36, -60, 50, 100, 120, 150, 200
io	ftgentmp 0, 0, 16, -2, 450, 800,  2830, 3500, 4950, 0,  -9, -16, -28, -55, 70,  80, 100, 130, 135
iu	ftgentmp 0, 0, 16, -2, 325, 700,  2530, 3500, 4950, 0, -12, -30, -40, -64, 50,  60, 170, 180, 200
igoto ind
soprano:
ia	ftgentmp 0, 0, 16, -2, 800, 1150, 2900, 3900, 4950, 0,  -6, -32, -20, -50, 80,  90, 120, 130, 140	
ie	ftgentmp 0, 0, 16, -2, 350, 2000, 2800, 3600, 4950, 0, -20, -15, -40, -56, 60, 100, 120, 150, 200	
ii	ftgentmp 0, 0, 16, -2, 270, 2140, 2950, 3900, 4950, 0, -12, -26, -26, -44, 60,  90, 100, 120, 120	
io	ftgentmp 0, 0, 16, -2, 450,  800, 2830, 3800, 4950, 0, -11, -22, -22, -50, 40,  80, 100, 120, 120	
iu	ftgentmp 0, 0, 16, -2, 325,  700, 2700, 3800, 4950, 0, -16, -35, -40, -60, 50,  60, 170, 180, 200
igoto ind

ind:
index	ftgentmp 0, 0, 16, -2, ia, ie, ii, ia, io, iu, ie, io, ii, iu, ia, io, ia, ia, ia, ia, ia


	ftmorf	kmorf, index, imorf

kfx	=	0
kform1	table	kfx,   imorf
kform2	table	kfx+1, imorf
kform3	table	kfx+2, imorf
kform4	table	kfx+3, imorf
kform5	table	kfx+4, imorf
kamp1	table	kfx+5, imorf
kamp2	table	kfx+6, imorf
kamp3	table	kfx+7, imorf
kamp4	table	kfx+8, imorf
kamp5	table	kfx+9, imorf
kbw1	table	kfx+10,imorf
kbw2	table	kfx+11,imorf
kbw3	table	kfx+12, imorf
kbw4	table	kfx+13, imorf
kbw5	table	kfx+14, imorf

iolaps	=	200
a1	fof	ampdbfs(kamp1),  kfund,  kform1,  koct, kbw1, .003,  .02,  .007,  iolaps,  ivib, ifenv,  p3
a2	fof	ampdbfs(kamp2),  kfund,  kform2,  koct, kbw2, .003,  .02,  .007,  iolaps,  ivib, ifenv,  p3
a3	fof	ampdbfs(kamp3),  kfund,  kform3,  koct, kbw3, .003,  .02,  .007,  iolaps,  ivib, ifenv,  p3
a4	fof	ampdbfs(kamp4),  kfund,  kform4,  koct, kbw4, .003,  .02,  .007,  iolaps,  ivib, ifenv,  p3
a5	fof	ampdbfs(kamp5),  kfund,  kform5,  koct, kbw5, .003,  .02,  .007,  iolaps,  ivib, ifenv,  p3
asig	=	a1+a2+a3+a4+a5

	xout	asig
endop

 
