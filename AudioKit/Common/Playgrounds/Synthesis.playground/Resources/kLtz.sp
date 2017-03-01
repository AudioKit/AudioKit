# kLtz
# by Paul Batchelor
# August 2016
# p0: 0.5   Tempo
# p1: 0.5   Probability
# p2: 0.25  Feedback
# p3: 0.25  Resonance

_trig 1 zeros
0 p 60 155 scale 4 * bpm2dur dmetro
1 p 0.2 1 scale maytrig dup 0 _trig tset 0.0001 0.004
0.001 0.03 10 randh tenvx
0.5 noise *
500 4000 3 p 3 40 scale randi 3 p 1.7 1.9 scale 1.11 wpkorg35
dup 2 p 0.1 0.99 scale
0 _trig tget 4 0 tdiv 0.001 0.29 trand
0.4 1024 smoothdelay 0.3 * +
dup
