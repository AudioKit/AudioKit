/*
BufPlay1 - Plays audio from a mono buffer (function table), with different options

DESCRIPTION
Plays audio from a mono buffer (function table), with control over speed (forward - backward), volume, start point, end point, and different options of wrapping/looping. All parameters can be modified during performance.
See the UDO BufFiPl if you want to play back a soundfile which has been loaded into a buffer. BufFiPl performs also sample rate conversion

SYNTAX
aout, kfin BufPlay1 ift, kplay, kspeed, kvol, kstart, kend, kwrap

INITIALIZATION
ift - function table to play. This can be a non-power-of-two function table (given by a negative size, see example), but no deferred size GEN01 table.

PERFORMANCE
kplay - 1 for playing, 0 (or any other number) stops playing
kspeed - 1 for playing back in the same speed as the buffer has been recorded, 2 for double speed etc., negative numbers for backwards
kvol - volume as multiplier (1=normal)
kstart - begin of playing the buffer in seconds
kend - end of playing in seconds. Zero means the end of the table
kwrap - 
kwrap = 0: no wrapping. Stops at kend (positive speed) or kstart (negative speed). This makes just sense if the direction does not change and you just want to play the table once 
kwrap = 1: wraps between kstart and kend
kwrap = 2: wraps between 0 and kend
kwrap = 3: wraps between kstart and end of table
aout - audio output signal
kfin - 1 if playing has ended (wrap=0), otherwise 0


CREDITS
joachim heintz 2010
*/

  opcode BufPlay1, ak, ikkkkkk
ift, kplay, kspeed, kvol, kstart, kend, kwrap xin
;CALCULATE BASIC VALUES
kfin		init		0
iftlen		=		ftlen(ift)/sr ;ftlength in seconds
kend		=		(kend == 0 ? iftlen : kend) ;kend=0 means end of table
kstart01	=		kstart/iftlen ;start in 0-1 range
kend01		=		kend/iftlen ;end in 0-1 range
kfqbas		=		(1/iftlen) * kspeed ;basic phasor frequency
;DIFFERENT BEHAVIOUR DEPENDING ON WRAP:
if kplay == 1 && kfin == 0 then
 ;1. STOP AT START- OR ENDPOINT IF NO WRAPPING REQUIRED (kwrap=0)
 if kwrap == 0 then
kfqrel		=		kfqbas / (kend01-kstart01) ;phasor freq so that 0-1 values match distance start-end
andxrel	phasor 	kfqrel ;index 0-1 for distance start-end
andx		=		andxrel * (kend01-kstart01) + (kstart01) ;final index for reading the table (0-1)
kfirst		init		1 ;don't check condition below at the first k-cycle (always true)
kndx		downsamp	andx
kprevndx	init		0
 ;end of table check:
  ;for positive speed, check if this index is lower than the previous one
  if kfirst == 0 && kspeed > 0 && kndx < kprevndx then 
kfin		=		1
 ;for negative speed, check if this index is higher than the previous one
  else
kprevndx	=		(kprevndx == kstart01 ? kend01 : kprevndx) 
   if kfirst == 0 && kspeed < 0 && kndx > kprevndx then
kfin		=		1
   endif
kfirst		=		0 ;end of first cycle in wrap = 0
  endif
 ;sound out if end of table has not yet reached
asig		table3		andx, ift, 1	
kprevndx	=		kndx ;next previous is this index
 ;2. WRAP BETWEEN START AND END (kwrap=1)
 elseif kwrap == 1 then
kfqrel		=		kfqbas / (kend01-kstart01) ;same as for kwarp=0
andxrel	phasor 	kfqrel 
andx		=		andxrel * (kend01-kstart01) + (kstart01) 
asig		table3		andx, ift, 1	;sound out
 ;3. START AT kstart BUT WRAP BETWEEN 0 AND END (kwrap=2)
 elseif kwrap == 2 then
kw2first	init		1 
  if kw2first == 1 then ;at first k-cycle:
		reinit		wrap3phs ;reinitialize for getting the correct start phase
kw2first	=		0 
  endif
kfqrel		=		kfqbas / kend01 ;phasor freq so that 0-1 values match distance start-end
wrap3phs:
andxrel	phasor 	kfqrel, i(kstart01) ;index 0-1 for distance start-end
		rireturn	;end of reinitialization
andx		=		andxrel * kend01 ;final index for reading the table 
asig		table3		andx, ift, 1	;sound out
 ;4. WRAP BETWEEN kstart AND END OF TABLE(kwrap=3)
 elseif kwrap == 3 then
kfqrel		=		kfqbas / (1-kstart01) ;phasor freq so that 0-1 values match distance start-end
andxrel	phasor 	kfqrel ;index 0-1 for distance start-end
andx		=		andxrel * (1-kstart01) + kstart01 ;final index for reading the table 
asig		table3		andx, ift, 1	
 endif
else ;if either not started or finished at wrap=0
asig		=		0 ;don't produce any sound
endif
  		xout		asig*kvol, kfin
  endop

 
