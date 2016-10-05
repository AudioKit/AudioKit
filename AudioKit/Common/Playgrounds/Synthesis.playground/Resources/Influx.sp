# Influx
# By Paul Batchelor
# July 2016

# Controls:
# p0: 0.5 Filter Cutoff
# p1: 0.5 Crazy Delay/Chorus Level
# p2: 0.5 Random Delay Portamento
# p3: 0.5 Tempo

"seq" "0 10 12 3 7 2" gen_vals
"seq2" "15 17 14 7 19" gen_vals
"dtime" "1.5 0.5 1 0.5" gen_vals
"dtime2" "0.5 0.25 0.25 1 1" gen_vals
"saw" 8192 "0 1 8191 -1" gen_line
_p 4 zeros

3.5 dmetro dup

0 0 rot 0.5 maygate 0.5 0.25 branch 0.5 *
# make the transition between the two sluggish
0.05 port

"dtime" dtrig 0.75 maytrig 1 _p tset

1 _p tget 0 "seq" tseq
1 _p tget 0.1 0.1 1 tenvx dup 0 _p tset
swap 58 + 0.01 port
0.1 1 5 jitter +
mtof

0 phasor
0 _p tget 0.2 port
1 2 0.1 randi
# multiply using the expon envelope
*
# multiply the phasor by some positive amount
# to do wrapping
*
1 0 1 "saw" tabread 0.5 * *

3 p 0.5 7 scale dmetro 1 0 0.5 "dtime2" dtrig
1 3 p - 0.2 1 scale maytrig
1 _p tset

# VOICE 2
1 _p tget 0 "seq2" tseq
1 _p tget 0.5 0.5 1 tenvx dup 0 _p tset
swap 58 + 0.01 port
0.1 1 5 jitter +
mtof

0 phasor
0 _p tget 0.2 port
3 5 0.1 randi
# multiply using the expon envelope
*
# multiply the phasor by some positive amount
# to do wrapping
*
1 0 1 "saw" tabread 0.5 * * +

0 p 100 1100 scale

0.99 1.4 wpkorg35

# Crazy glitchy delay thing
dup 0.9
1 _p tget 0.001 0.2 trand 1 2 p - 0.001 5 scale port
0.8 vdelay 1 p -40 0 scale 0.01 port ampdb * 2000 buthp
# i d1a d1b
dup 0.1 *

# d1a d1b i i
rot dup
# d1a i (d1b + i)
rot +
0.8 0.8 delay 0.4 * 400 butlp
-4 ampdb *


+ +
dup -7 2048 1024 pshift + 0.5 *
dup -7 2048 1024 pshift + 0.5 *

dcblk
dup
