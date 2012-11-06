/*
FilePlay2 - Plays a stereo signal from a mono or stereo soundfile

DESCRIPTION
Gives stereo output regardless a soundfile is mono or stereo (if mono, this signal is sent to both channels).

SYNTAX
aL, aR FilePlay2 Sfil, kspeed [, iskip [, iloop]]

INITIALIZATION
Sfil - Sound file name (or path) in double quotes
iskip - skiptime in seconds (default=0)
iloop - 1 = loop, 0 = no loop (default=0)

PERFORMANCE
kspeed - speed to read the file (1 = normal, 2 = octave higher, 0.5 = octave lower)

CREDITS
joachim heintz july 2010
*/

  opcode FilePlay2, aa, Skoo
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aL		diskin2	Sfil, kspeed, iskip, iloop
aR		=		aL
else
aL, aR		diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aL, aR
  endop
 
