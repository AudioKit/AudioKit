/*
ampSlider - Converts a scaled (0-1) value to a value resembling a hardware mixer slider.

DESCRIPTION
Converts a scaled (0-1) value to a scaled amplitude value resembling a volume slider attenuation on a hardware mixer (-inf dbfs to +10dbfs). 

SYNTAX
kamp ampSlider kdb

INITIALIZATION
kdb -- a normalized value 0 - 1

PERFORMANCE
Actual range of values returned are around (0-3), with a value of 1 (0dbfs) being
returned when the input is around .85.  

This opcode uses the ampdbN UDO.

CREDITS
ma++, jan 2005
*/

opcode ampSlider, k, k
	
	kvalue xin
	kvalue ampdbN kvalue/.87
	kvalue pow kvalue, .8
	xout kvalue

endop
 
