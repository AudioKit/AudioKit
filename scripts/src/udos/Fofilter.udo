/*
Fofilter - A formant filter version of the FOF opcode.

DESCRIPTION
This filter generates a stream of overlapping sinewave grains, when fed with a pulse train. Each grain is the
impulse response of a combination of two BP filters. The grains are defined by their attack time (determining the skirtwidth of the formant region at 
-60dB) and decay time (-6dB bandwidth). Overlapping will occur when 1/freq <  decay, but, unlike FOF, there is no upper limit on the number of overlaps.
The original idea for this opcode came from J McCartney\'s formlet class in SuperCollider, but this is
possibly implemented differently (?).

SYNTAX
ar   Fofilter   asig, kcf, kris, kdec

PERFORMANCE
asig - input signal 
kcf - formant center frequency (Hz)
kris - impulse response attack time (secs)
kdec - impulse response decay time (to -60dB, in secs)

CREDITS
Victor Lazzarini
*/

opcode Fofilter, a, akkk

   setksmps 1

ipiosr = 4*taninv(1)/sr  /* pi/sr */
af1z1 init 0             /* filter delays */
af1z2 init 0
af2z1 init 0
af2z2 init 0

asig,kcf,kris,kdec  xin

kang = 2*ipiosr*kcf   /* pole angle */
kfsc = sin(kang) - 3  /* freq scl   */
krad1 =  10^(kfsc/(kdec*sr))  /* filter radii */
krad2 =  10^(kfsc/(kris*sr))

aw1  = asig + 2*krad1*cos(kang)*af1z1 - krad1*krad1*af1z2
adec =  aw1 - af1z2
af1z2 = af1z1
af1z1 = aw1

aw2  = asig + 2*krad2*cos(kang)*af2z1 - krad2*krad2*af2z2
att =  aw2 - af2z2
af2z2 = af2z1
af2z1 = aw2
       
        xout  adec - att     
	
endop
 
