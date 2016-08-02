# Distance Intelligence
# By Paul Batchelor July 2016


# Control 1: pitch
# Control 2: tempo
# Control 3: FM Brightness
# Control 4: FM Detune

_seq '67 69 71 72 74 76' gen_vals
_amps '1.0 0.5 0.25 0.5' gen_vals

_args 4 zeros

60 mtof 4 pset

_pad 262144 4 p 40 'amps' gen_padsynth

1 p 40 200 scale 4 * bpm2dur dmetro

0.6 maytrig dup 0 _args tset
0.002 0.004 0.2 tenvx

0 p 0 4 scale floor _seq tget

0.1 port
mtof dup 2 _args tset 0.2
1
0 _args tget 0 5 trand dup floor 3 p cf
2 p 0.5 port 0 3 scale
fm *

2 _args tget 4 p / _pad tbldur / 0 phasor
1 0 0 _pad tabread 0.1 * +

dup dup 5 8 3000 zrev drop 0.3 * +
