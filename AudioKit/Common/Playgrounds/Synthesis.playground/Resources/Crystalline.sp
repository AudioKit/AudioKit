##: # Crystalline
##: Another sporthling created for the AudioKit sporth editor. It features
##: a Karplus-Strong pluck and a phase-vocoder buffer shuffler.
##: The controls are the following:
##: - Control 1: Feedback
# default 0.92
##: - Control 2: Tempo
# default 0.086
##: - Control 3: Dry/Wet
# default 0.61
##: - Control 4: Probability
# default 0.519

##:
##: ## Setup
##:

0 p "p0" print drop
1 p "p1" print drop
2 p "p2" print drop
3 p "p2" print drop

##: A buffer for audio is created and zeroed out.
##---
'buf' 80000 zeros
##---

##: An argument table is created to store some parameters.
##---
_tk 2 zeros
##---

##: A table is created containing a musical sequence.

##---
'seq' '0 2 7 11 14 4 2' gen_vals
##---

##:
##: ## Clock
##:

##: **tick** will output a single trigger at the start of a sporth patch.
##: It can only be used once, so the output must be copied somewhere else, in
##: this case our table *tk*.

##---
tick 0 _tk tset
##---

##: Our clock consists of 3
##: parts:

##: the tick signal, guaranteeing a trigger at the beginning of the patch,
##---
0 _tk tget
##---

##: the metronome signal, whose rate is set by p-register 1,

##---
1 p 1 5 scale metro
##---

##: and the metronome goes into the maytrig, whose probability is determined by
##: p-register 3.

##---
3 p 0.4 1.0 scale
maytrig +
##---

##: This clock signal is copied into index 1 of the table *tk* for later use,
##: then duplicated for more imediate use. *(It is also possible to
##: use table instead of the stack, but the patch evolved this way.)*

##---
dup 1 _tk tset
dup
##---

##:
##: ## Pluck
##:

##: The Karplus Strong pluck is the fundamental sound source in this patch.
##: The other aspects of the patch process this sound.
##:
##: The clock signal from the previous section triggers a tseq, whose mode
##: is 0, which means it will move sequentially through the table.

##---
0 'seq' tseq
##---

##: This sequence is biased to 61 (Db major ish), and converted to a frequency
##: via mtof.

##---
61 + mtof
##---

##: The rest of the pluck module is pretty typical. It is put through a lowpass
##: filter to smooth out the pluck sound a bit.

##---
0.9 400 pluck 1000 butlp
##---

##: The pluck is split and put into a static delay line, whose feedback is
##: determined by p-register 0.

##---
dup 0 p 0.01 0.9 scale 0.01 port 0.75 delay
##---

##: The output of the delay is put through a highpass filter and attenuated
##: a little bit. Then, it is mixed back into the dry signal.

##---
1000 buthp 0.7 * +
##---

##: The pluck is fed into the zita-reverb with a very long decay time.
##: A dc blocker is put on the end of it for good measure.

##---
dup dup 10 10 8000 zrev drop 0.5 * + dcblk
##---

##: The entire signal created so far is sent into **tblrec**, which "records"
##: the audio input into the buffer. The tick signal created earlier is needed
##: here for **tblrec**, which will leave it recording indefinitely.

##---
0 _tk tget 'buf' tblrec
##---

##:
##: ## Mincer
##:

##: Mincer is a phase vocoder, which allows control of position and pitch
##: of an ftable independent of one another. In this case, the ftable being
##: used is the buffer, which is being constantly rewritten via **tblrec**
##:

##: Wavetable position is a slow random walk.

##---
0 'buf' tbldur 0.3 randi
##---

##: Ampltiude is 1. No attenuation.

##---
1
##---

##: Next argument is the playback rate.
##: The clock signal drives a random number generator, which picks values between
##: 1 and 3. These numbers are truncated to be integers via floor.
##: This is done so the play back rate can be one of three states: normal (1),
##: one octave up (2), and one octave and fifth up (3). Restricting these states
##: makes things sound more pretty and in key.

##---
1 _tk tget 1 3 trand floor
##---

##: The last argument of mincer is the buffer.

##---
2048 'buf' mincer
##---

##:
##: ## Chorusing Delay
##:

##: The output of mincer is sent into this chorusing delay effect. It is a
##: feedback delay sent through a (surprise) chorus made up of pitch shifters.
##:
##: The feedback delay has a somewhat high feedback, and a very long delay time.

##---
dup 0.7 1.5 delay 0.7 *
##---

##: The output of this delay is put into two pitch shifters in parallel.
##: The first pitch shifter raises the pitch by 0.11 semitones, the second
##: drops the pitch by 0.1 semitones. The dry delayline signal and pitch
##: shifters are then mixed together.

##---
dup 0.11 1024 512 pshift
rot dup -0.1 1024 512 pshift + +
##---

## The chorus delay and the mincer signal are summed, then attenuated by
## -10 dBfs.

##---
+ -10 ampdb *
##---

##:
##: ## Wet/Dry
##:

##: At this point, there are two items on the stack: the pluck signal,
##: and the chorused mincer signal. A crossfade is used to switch between
##: these two signals. The position of this crossfade is determined by
##: p-register 2. The subtraction is needed to flip the signals.
##: The final signal is duplicated to work on a stero signal.
##---
1 2 p 0.01 port - cf
##---
dup
