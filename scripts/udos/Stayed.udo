/*
Stayed - Reports if a control signal has stayed at the same value for a certain time. 

DESCRIPTION
Outputs 1 if kin has not changed since at least ksec seconds, otherwise outputs 0.

SYNTAX
kout Stayed kin, ksec

PERFORMANCE
kin - input signal
ksec - time in seconds for which kin is asked to have the same value or not
kout - 1 if the value has not changed since at least ksec seconds, otherwise 0

CREDITS
joachim heintz 2010
*/

  opcode Stayed, k, kk
kin, ksec	xin
kout		init		0
knumk		=		ksec * kr ;number of control cycles for ksec
kinit		init		1
kcount		init		0
 if kinit == 1 then		;just once, at the beginning
kprevious	=		kin
kinit		=		0
 endif
 if kin == kprevious then
kcount		=		kcount + 1
 else
kcount		=		0
kprevious	=		kin
 endif
 if kcount > knumk then
kout		=		1
 else
kout		=		0
 endif
		xout		kout
  endop
 
