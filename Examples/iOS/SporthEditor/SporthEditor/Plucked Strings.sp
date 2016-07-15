"seq" "55 62 67 62 64" gen_vals

"seq2" "55 57 59 55 57 60 55 57 52 52 50 55" gen_vals

125 2 p 125 * + 0 pset

60 0 p / 0.5 * dmetro 0.6 maytrig dup
0 "seq" tseq mtof
0.3
110
pluck


0 p "+-2(+--+)----" prop dup
0 "seq2" tseq mtof dup 1 pset
0.3
86.0
pluck

1 p 0.5 * 1 sine *

+

dup 0.7 60 0 p / 0.75 * delay 3000 butlp 0.4 * +

