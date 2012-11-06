/*
bends - Pitchbend with center 1 suitable for use with microtonal scales (see tunk, tunkb)

DESCRIPTION
bends is designed to allow pitchbend by ratio multiplication. It is intended for use in combination with tunk, producing tunkb. When the pitch wheel is at rest, bends outputs a value of 1.

SYNTAX
kbend bends ibnd

INITIALIZATION
ibnd: must be greater than zero and less than two. A value of 0.5 will give a bend range of -/+ a fifth

CREDITS
Jonathan Murphy
*/

    opcode bends, k, i

  ibnd	    xin
  kbend	    init      1
  ihi	    =  1 + ibnd
  ilo	    =  1 - (ibnd * 0.5)
  gilo	    ftgen     0, 0, 64, -16, ilo, 63, 0, 1
  gihi	    ftgen     0, 0, 64, -16, 1, 63, 0, ihi
  kst, kch, kd1, kd2  midiin
if (kst == 224) then
  kbnd	    =  kd1 + (kd2 * 127)
  kbnd	    =  kbnd/128
if (kbnd < 64) then 
  kbend	    table     kbnd, gilo
elseif (kbnd >= 64) then
  kbend	    table     kbnd - 64, gihi
endif
endif
	    xout      kbend

    endop
 
