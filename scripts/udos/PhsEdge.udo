/*
PhsEdge - Reports whether the upper or lower border of a phasor has been reached.

DESCRIPTION
Reports whether a phasor has reached its upper border 1 when running with positive frequency (forwards), or its lower border 0 when running with negative frequency (backwards)

SYNTAX
kend PhsEdge kphs, kfq, ktrig [, iphs]

INITIALIZATION
iphs - starting phase of the phasor (default=0)

PERFORMANCE
kphs - phasor output (range 0-1)
kfq - phasor frequency
ktrig - 1 for start, any other number bypasses
kend - returns '1' just once in a k-cycle whenever the upper or lower border has been reached (see examples)

CREDITS
joachim heintz 2010
*/

  opcode PhsEdge, k, kkko
kphs, kfq, ktrig, iphs xin 
kfirst		init		1 ;don't check in first k-cycle
if ktrig == 1 then ;don't do anything if not turned on
 if kfirst == 1 then ;first k-cycle
;set previous phase value to 1 if negative frequency and phasor starting from the beginning (for avoiding kend=1 immediately after start), otherwise previous phase is set to 0
kprevphs	=		(kfq < 0 && iphs == 0 ? 1 : iphs)
kfirst		=		0 ;end of first cycle 
 else ;after first k-cycle
  ;for positive speed, check if this index is lower than the previous one
  if kfq > 0 && kphs < kprevphs then
kend		=		1
 ;for negative speed, check if this index is higher than the previous one
  elseif kfq < 0 && kphs > kprevphs then
kend		=		1
  else ;no end reached
kend		=		0
  endif
kprevphs	=		kphs ;next previous is this phase
 endif
else ;bypass if no trigger
kend		=		0
endif
		xout		kend
  endop
 
