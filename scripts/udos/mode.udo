/*
mode - filter that simulates a mass-spring-damper system

DESCRIPTION
Filters the incomming signal with the specified resonance frequency and quality factor.

It can also be seen as a signal generator for high quality factor, with an impulse for the excitation.

You can combine several modes to built complex instruments, as bells, or guitar table.

SYNTAX
aout mode ain, ifreq, iQ

PERFORMANCE
aout  -- filtered signal
ain   -- signal to filter
ifreq -- resonant frequency of the filter (!!!!! WARNING !!!! Becomes unstable if sr/ifreq < pi (e.g ifreq>14037 Hz @44kHz) !!!!!!!)
iQ    -- quality factor of the filter

resonance time is roughly proportionnal to iQ/ifreq

CREDITS
François Blanc, 2006
*/

opcode mode, a,aii

ain,ifreq,iQ xin;Inputs args : signal to filter, resonant frequency, quality factor

setksmps 1
ipi init 355/113 ;approximation of pi = 3.14....
ay1 init 0
ay2 init 0
ax1 init 0

ax1 delay1 ain
ifreq  = ifreq*2*ipi
ialpha = (sr/ifreq)
ibeta  = ialpha*ialpha;



aout = (-(1-2*ibeta)*ay1 + ax1 - (ibeta-ialpha/(2*iQ))*ay2)/(ibeta+ialpha/(2*iQ));

ay2 = ay1
ay1 = aout

aout = aout*sr/(2*ifreq)

xout aout

endop
 
