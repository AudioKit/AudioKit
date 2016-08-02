'seq' '69 71 73 74 68' gen_vals
1 p 30 220 scale 4 pset
2 p 0.01 2 scale 5 pset

4 p bpm2rate metro 3 0 tdiv 0 p maytrig
0.001 0.1 5 p tenvx
33 mtof 0.3 1 3 3 fm * dup 6 pset

4 p 4 * bpm2rate metro 0 p maytrig
0.001 0.1 5 p tenvx
57 mtof 0.3 1 1 1 fm *

4 p 3 * bpm2rate metro 0 p maytrig
0.001 0.1 5 p tenvx
64 mtof 0.3 1 1 1 fm *

4 p 2 * bpm2rate metro 0 p maytrig
dup
0.004 0.1 5 p tenvx
swap 3 0 tdiv 0 'seq' tseq mtof 0.3 1 1 1 fm *

mix
0.3 *

6 p dup 0.96 10000 revsc drop 0.1 * 1 1 p - * 200 buthp  +
dup

# slider 1: probability
# slider 2: speed (also inverse reverb send)
# slider 3: release time