# Simple Keyboard
# by Aurelius Prochazka and Paul Batchelor

##: - Control 1: Portamento
# default 0.001
##: - Control 2: Modulating Multiplier
# default 1
##: - Control 3: Modulation Index
# default 1
##: - Control 4: Reverb Mix
# default 0.5

# Uses Keyboard

5 p # MIDI Note Number
0 p 0.001 0.2 scale port mtof # Frequency
0.5 1                         # Amplitude, Carrier Multiplier
1 p 0 8 scale floor           # Modulating Multiplier
2 p 0 5 scale                 # Modulation Index
fm

4 p # On/Off gate
0.1 port *
dup dup
0.93 10000 revsc drop
3 p 0 0.2 scale * +
dup
