# Simple Keyboard
# by Aurelius Prochazka and Paul Batchelor

# p0: 0.001 Portamento
# p1: 1     Modulating Multiplier
# p2: 1     Modulation Index
# p3: 0.5   Reverb Mix
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