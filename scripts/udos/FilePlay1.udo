/*
FilePlay1 - Plays a mono signal from a mono or stereo soundfile

DESCRIPTION
Gives mono output regardless a soundfile is mono or stereo (if stereo, just the first channel is used).

SYNTAX
aout FilePlay1 Sfil, kspeed [, iskip [, iloop]]

INITIALIZATION
Sfil - Sound file name (or path) in double quotes
iskip - skiptime in seconds (default=0)
iloop - 1 = loop, 0 = no loop (default=0)

PERFORMANCE
kspeed - speed to read the file (1 = normal, 2 = octave higher, 0.5 = octave lower)

CREDITS
joachim heintz july 2010
*/

  opcode FilePlay1, a, Skoo
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, kspeed, iskip, iloop
else
aout, ano	diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aout
  endop
 
