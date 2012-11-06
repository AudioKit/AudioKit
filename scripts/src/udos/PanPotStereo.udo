/*
PanPotStereo - pans stereo input to stereo output

DESCRIPTION
Pans stereo input to stereo output. The behaviour should be the same as in an audio editor or a mixer:
pan pot "middle" gives 100% of L and R input;
"very left" gives 100% L and 0% R;
"half left" gives 100% L and 50% R;
and so on.

SYNTAX
aoutL, aoutR PanPotStereo ainL, ainR, kpan

PERFORMANCE
ainL, ainR - audio input
kpan - panning from 0=left to 1=right
aoutL, aoutR - sudio output

CREDITS
joachim heintz 2009
*/

opcode PanPotStereo, aa, aak
ainL, ainR, kpan xin ;kpan 0=left to 1=right
kpan = (kpan < 0 ? 0 : (kpan > 1 ? 1 : kpan))
kmultL = (kpan < 0.5 ? 1 : (1 - kpan) * 2)
kmultR = (kpan > 0.5 ? 1 : kpan * 2)
aoutL = ainL * kmultL
aoutR = ainR * kmultR
xout aoutL, aoutR
endop
 
