# Plucked Strings
# by Paul Batchelor

# p0: 0.5 Randomness?
# p1: 0.5 Mix?
# p2: 0.5 Gain?

# Create buffer with length 80000 samples
'buf' 80000 zeros

# tick can only be called once in a Sporth patch
# so set it to a p-register (4) so the signal can
# be duplicated
tick 4 pset

# Create a sequence
'seq' '0 2 7 11 14 4 2' gen_vals

# our maygate clock with a guaranteed start
3 p 1 metro 0.7 maytrig +
# duplicate the clock signal for tseq and pluck
dup

# sequence through the table
0 'seq' tseq
# bias 61 (Db major) and convert to frequency for pluck
61 + mtof
0.9 400 pluck 1000 butlp

# delayz for dayz
dup 0.6 0.75 delay 1000 buthp 0.7 * +

# reverb
dup dup 10 10 8000 zrev 0.5 * drop + dcblk


# duplicate our entire signal and record it in buffer
dup 2 p * swap 4 p 'buf' tblrec

# mincer object shuffles through recording buffer
0 'buf' tbldur
0 p randi 1
1.5 'buf' mincer 1 p *

# Sum mincer with everything else
+

