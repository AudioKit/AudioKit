# Crystalline
# By Paul Batchelor
# August 2016
# p0: 0 Feedback
# p1: 0 Tempo
# p2: 0 Dry/Wet
# p3: 0 Probability

'buf' 80000 zeros

_tk 2 zeros
tick 0 _tk tset

'seq' '0 2 7 11 14 4 2' gen_vals

0 _tk tget
1 p 1 5 scale
metro
3 p 0.4 1.0 scale
maytrig + dup 1 _tk tset
dup

0 'seq' tseq
61 + mtof
0.9 400 pluck 1000 butlp

dup

0 p 0.01 0.9 scale 0.01 port
0.75 delay 1000 buthp 0.7 * +

dup dup 10 10 8000 zrev 0.5 * drop + dcblk


dup swap 0 _tk tget 'buf' tblrec

0 'buf' tbldur

0.3 randi 1

1 _tk tget 1 3 trand floor 'buf'

mincer

dup 0.7 1.5 delay 0.7 *
dup 0.11 1024 512 pshift
rot dup -0.1 1024 512 pshift + +
+
-10 ampdb *

1 2 p 0.01 port -  cf

dup