# Chatting
# By Paul Batchelor July 2016

'f1' '350 600 400' gen_vals
'f2' '600 1040 1620' gen_vals
'f3' '2400 2250 2400' gen_vals

'g1' '1 1 1' gen_vals
'g2' '0.28184 0.4468 0.251' gen_vals
'g3' '0.0891 0.354 0.354' gen_vals

'bw1' '40 60 40' gen_vals
'bw2' '80 70 80' gen_vals
'bw3' '100 110 100' gen_vals

0 2 0.1 1 sine 2 10 biscale randi 0 pset
110 200 0.8 1 sine 2 8 biscale randi 3 20 30 jitter +
0.2 0.1 square dup 0 p 0 0 0 'g1' tabread *

0 p 0 0 0 'f1' tabread
0 p 0 0 0 'bw1' tabread butbp swap dup
0 p 0 0 0 'g2' tabread *
0 p 0 0 0 'f2' tabread
0 p 0 0 0 'bw2' tabread butbp swap
0 p 0 0 0 'g3' tabread *
0 p 0 0 0 'f3' tabread
0 p 0 0 0 'bw3' tabread

butbp + + 0.4 dmetro 0.5 maygate 0.01
port * 2.0 * dup jcrev +
