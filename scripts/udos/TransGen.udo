/*
TransGen - Transient envelope generator, pulse divider, and/or LFO.

DESCRIPTION
Inspired by the design of the transient generator module in the Serge Modular analog synthesizer, TransGen responds to a trigger input with a value of 1 by creating a variable-rate rise/fall transient signal. It outputs a trigger value of 1 at the beginning of each new rise/fall cycle, and a gate/trigger signal with a value of 1 at the end of each cycle. Multiple TransGen units can be chained, so that A triggers B, which triggers C, which in turn triggers A again. Or B could trigger C, D, and E, all starting at the same time but with different lengths.

When the trigger input is 1 continuously, TransGen will loop, making it a triangle-wave LFO with individual control over rise and fall times, but no direct control over the length of the cycle as a whole.

TransGen can also act as a clock divider, because it outputs a trigger (kstarting) at the beginning of each new cycle and a trigger/gate (kdone) when its cycle is finished. If a new input trigger arrives while the envelope is active, the input trigger is ignored, and neither kstarting nor kdone changes.

SYNTAX
kenv, kstarting, kdone		TransGen	ktrig, krise, kfall, kfloor, ktop[, imode][, idone]

INITIALIZATION
imode -- optional, default 0. When 0, the values of krise and kfall are interpreted in seconds. When 1, krise and kfall are interpreted as rates.

idone -- optional, default 1. Useful only when kfloor is greater than ktop. When this condition occurs, the output value for the trigger/gate kdone, sent at the end of the rise/fall cycle, will be the value stipulated by the idone input. An idone value of 0 can be useful.

PERFORMANCE
kenv -- A contour signal that begins at kfloor, rises to ktop, and falls back to kfloor at rate/times specified by krise and kfall.

kstarting -- A trigger output of 1 at the beginning of each new rise/fall cycle; otherwise zero.

kdone -- A trigger/gate output. Zero while the rise/fall cycle is ongoing, and 1 otherwise.

ktrig -- When the ktrig input is 1, it initiates a new rise/fall cycle, but only if no rise/fall cycle is currently occurring. If a rise/fall cycle has started but not completed, a new 1 at the ktrig input is ignored.

krise -- The rise time in seconds (if imode is 0) or the rise rate (if imode is 1). If imode==1, then the formula ksmps * irise / 100000 defines the amount by which the envelope will rise or fall in each k-period. With a range from floor to top of 1, ksmps=10, and sr=44100, a value of 2.2676 will produce a 1-second rise or fall time. With these settings, the most useful values for rate will probably lie between 200 (rapid rise or fall) and 0.2 (more gradual rise or fall).

kfall -- The fall time in seconds (if imode is 0) or the fall rate (if imode is 1). See krise for details.

kfloor -- The lowest value that will be output, at the end of the rise/fall cycle. If kfloor ever becomes greater than ktop, the kenv output assumes the value of ktop. If the level of ktop subsequently rises past kfloor, cycling will resume. 

ktop -- The highest value that will be output, at the peak of the rise/fall cycle. In normal usage ktop should be greater than kfloor, but this condition is not enforced. (See idone.)

CREDITS
By Jim Aikin
*/

opcode TransGen, kkk, kkkkkop

ktrig, krise, kfall, kfloor, ktop, imode, idone		xin

kenv init 0
krisedone init 0
kfalldone init 0
kdone init 1
kfixed init 0
klevel init 0
kstarting init 0

; input error trapping:
if kfloor > ktop then
	if kfixed == 0 then
		kenv = ktop
		kfixed = 1
	endif
	kdone = idone
	kgoto nocycle
endif

krange = ktop - kfloor

if imode == 0 then
	kriseinc = ((krise > 0) ? (1 / (kr * krise)) : 1) * krange
	kfallinc = ((kfall > 0) ? (1 / (kr * kfall)) : 1) * krange
else
	kriseinc = ksmps * krise / 100000
	kfallinc = ksmps * kfall / 100000
endif

if ktrig == 1 then
	if kdone == 1 then
		kenv = kfloor
		krisedone = 0
		kfalldone = 0
		kdone = 0
		kstarting = 1
	else
		kstarting = 0
	endif
else
	if kdone == 1 kgoto nocycle
endif

; generate the contour:
    
if krisedone == 0 then
	kenv = kenv + kriseinc
	if kenv >= ktop then
		kenv = ktop
		krisedone = 1
	endif
endif

if krisedone == 1 && kfalldone == 0 then
	kenv = kenv - kfallinc
	if kenv <= kfloor then
		kfalldone = 1
		kdone = 1
		kenv = kfloor
	endif
endif
	
nocycle:
    
    xout	kenv, kstarting, kdone

endop
 
