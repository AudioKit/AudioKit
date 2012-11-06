/*
pan_delay_and_filtered - Pan using delay and filters

DESCRIPTION
Panning User Defined Opcodes
Conversion of Hans Mikelson's examples in the Csound Magazine
Autumn 1999
   http://csounds.com/ezine/autumn1999/beginners/

SYNTAX
a1, a2    pan_delay_and_filtered    asig, kpan, kfco, iq

CREDITS
Author: Hans Mikelson, converted by Steven Yi
*/

	opcode pan_delay_and_filtered, aa, akki
asig, kpan, kfco, iq	xin

aflt	moogvcf asig, kfco, iq  

kdclki	linseg  0, .002, 1, p3-.002, 1                ; Fade in  envelope
kdclko	linseg  1, p3-.002, 1, .002, 0                ; Fade out envelope


kangle	= kpan * 3.14159265359 * .5 ; Compute pan*pi/2

kpanl	= sin(kangle)          ; Left pan value
kpanr	= cos(kangle)          ; Right pan value

kpl	= kpanl*.5+.5                   ; Generate a value between .5 and 1
kpr	= kpanr*.5+.5                   ; Generate a value between .5 and 1

adell	vdelay3 aflt*kdclki, kpanr*.7+.05, 2 ; Delay left  side .05 to .7 msec
adelr	vdelay3 aflt*kdclki, kpanl*.7+.05, 2 ; Delay right side .05 to .7 msec

afltl	butterlp adell, 4000+kpanl*10000     ; Generate a low pass filtered signal
afltr	butterlp adelr, 4000+kpanr*10000     ; Same for the right side

aoutl	= adell*kpan+afltl*(1-kpan)     ; Crossfade between delayed and filtered signal
aoutr	= adelr*(1-kpan)+afltr*kpan     ; Same for the right side

	xout    aoutl*kpl*kdclko, aoutr*kpr*kdclko ; Declick and output
	endop

 
