/*
getFrequency - Returns frequency whether being passed in pch or frequency

DESCRIPTION
Returns frequency whether being passed in PCH notation or frequency.  This code is commonly found in instruments designed to take in either pch or frequency values. Assumes that values lower than 15 are pch, and those higher than that are frequency.

SYNTAX
ifreq    getFrequency ival

INITIALIZATION
ival - input value, either pch or frequency

ifreq - output frequency

CREDITS
Steven Yi
*/

	opcode getFrequency, i, i

ipch 	xin
iout	= (ipch < 15 ? cpspch(ipch) : ipch)	
	xout	iout

	endop
 
