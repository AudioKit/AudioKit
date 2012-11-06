/*
MS2S - Converts a floating point number in the format min.sec to seconds

DESCRIPTION
Converts a floating point number in the format min.sec to seconds

SYNTAX
isec MS2S iminsec

INITIALIZATION
iminsec - a float in the format min.sec. the first two digits of the fractional part are the full seconds, the following ones mean 1/10, 1/100, ... seconds. See the examples below.
isec - number of seconds equating iminsec

CREDITS
joachim heintz 2011
*/

  opcode MS2S, i, i
ifloat		xin
imin		=		int(ifloat)
isec		=		frac(ifloat) * 100
		xout		imin*60 + isec
  endop

 
