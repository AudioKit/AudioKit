##: # Scheale
##:
##---
# Scheale
# By Paul Batchelor
# August 2015
##---
##:
##: As the date in original comment header would suggest,
##: *Scheale* was one of the first compositions written in Sporth.
##: *Scheale* was written in the mountains of Pennsylvania on an old
##: thinkpad laptop while overlooking Ganoga lake. As it so happens, I find
##: myself writing this documentation up, sitting in the same place a year later.
##:
##: Many things have changed since this piece was written. Maygate, for instance
##: used to be combination of maytrig and maygate. Arithmetic opererations
##: would words like mul, div, add, sub and not /, \*, +, and -. Clip has gone
##: through some fixes as well. Nevertheless, the essence of *Scheale* remains
##: the same.
##:
##: This patch is the main component of *Scheale*. The entirety of the composition
##: contains two Sporth patches and nature samples recorded
##: where this piece was mostly written.
##:
##: ## Table generation
##:
##: The tables used in this piece contain two pitch sets, which are swtiched
##: back and forth between one another. The first sequence contain the pitches
##: D, A, E, A.

##---
"seq_1"
"62 69 64 69"
gen_vals
##---
##: The second sequence contains pitches C sharp, E, F sharp, and B.

##---
"seq_2"
"73 76 66 71"
gen_vals
##---
##:
##: ## Clock source
##:
##: The main clock source used is the *prop* ugen. Prop was a micro-notation
##: language I wrote prior to writing Sporth. I have since then created
##: a port of in to exist inside Soundpipe and Sporth. The rhythm used
##: is "+2(++)--", which can be read is a quarter, two eigths, followed by
##: two quarter rests. The tempo is set to a rather slow 54 BPM.
##:
##: The output of clock is sent through a branch. This was initially done
##: in order to add a delay to the start of the patch in the larger composition.
##: Since this is only one part of the composition, the branch has been permantly
##: set to choose the prop clock source.

##---
1
54 "+2(++)--" prop 0 branch
##---
##: The output clock signal is put through a maytrig, which makes the clock
##: trigger 78 percent of the time. It is then duplicated on the stack.

##---
0.78 maytrig dup
##---
##:
##: ## Envelopes
##:
##: The main envelope used is *tenv*, a triggered linear envelope generator.
##: the release time of the envelope is randomized via *randi* to be between
##: 500 and 800 milliseconds.
##---
0.004 0.05 0.5 0.8 0.2 randi tenv
##---
##: After *tenv*, the clock signal is brought back to the top of the stack
##: and duplicated, so it can be used in the modal filters.
##---
swap dup
##---
##:
##: ## Modal filters
##:
##: The main means of sound generation uses a technique known as modal
##: synthesis. An impulse (created from the clock)
##: is sent through a series of modal filters, where
##: resonances are added to create percusive sounds that are somewhere between
##: metallic and glass. The first series of modal filters here is used
##: to create an excitation signal. Later on, they will be fed into
##: another series of modal filters to create a sounding pitch.
##---
dup 1000 12 mode
swap 3000 8 mode
add 0.3 mul dup
##---
##:
##: ## Sequencing
##:
##: The sequencing part of *Scheale* is by far the trickiest thing to
##: understand, due to the heavy use of stack operations (tables and variables
##: did not exist at this time).
##:
##: At its core, the sequencer is made up of two tseqs  being fed by the clock
##: signal in parallel. The stack operations used are meant to bring shuffle
##: the clock signal to tseq.

##---
rot dup dup 0 "seq_2" tseq
swap dup 0 "seq_1" tseq
##---
##: At this point, the stack has now been prepared in such a way so that the
##: last three items look like this: tseq1, clock, tseq2. The clock is swapped
##: into a 50-50 maytrig, which becomes the trigger that switches between
##: the two sequences via switch. Because trig is the first argument, and
##: not the last, two rots are ended to align the arguments correctly.
##---
swap 0.5 maytrig rot rot switch
##---
##: The clock signal (yes, there is still a copy of the clock signal
##: on the stack), is used again to drive a counter that counts from zero
##: to two. Every time it reaches 0, 12 is added to the sequence. In other
##: words, every three notes the sequence leaps an octave.
##---
swap 3 0 count 0 eq 12 0 branch add
##---
##: To add some glissando in between the notes, a portamento filter is
##: added to the signal before they are fed into the modal filters.
##---
0.001 port
##---
##:
##: ## More modal filters
##:
##: Now that an excitation signal and a sequence has been created, these
##: can be fed into the second series of modal filters which will create
##: the pitched sounds.
##:
##: Slight jitter is added onto the note sequence before it is converted
##: to a frequency. This is a crude attempt to add the "drift" commonly
##: experienced in analogue hardware.
##---
-0.15 0.15 0.2 randi add
##---
##: The midi note number is converted to frequency. The stack is shuffled
##: in such a way so that the arguments line up for the first modal filter,
##: and so there is also a copy of the frequency on the stack. The Q of the
##: filter is randomized via *randi*.

##---
mtof dup rot swap
300 2000 0.12 randi mode
##---
##: Once again the arguments on the stack are aligned for the second
##: modal filter. The Q of this filter is also randomized with a different
##: *randi*.
##---
swap rot swap 2.01081 mul 100 1000 0.1 randi mode
##---
##: The two modal filters are summed together, then scaled down, as they
##: are very very loud.

##---
add 0.15 mul
mul
##---

##:
##: Effects
##:
##: The effects used consist of clip distortion, a feedback filtered delay line,
##: and a very large reverb.
##:
##: Firstly, the sound is put through clip distortion, highly truncating
##: the waveform to give it grit. This is then dulled via a butterworth
##: lowpass filter.
##---
0.3 clip 1000 butlp
##---
##: This signal is fed through a delay line of 750 milliseconds. It is
##: attenuated and fed through another 1000Hz lowpass filter.

##---
dup 0.76 0.75 delay 0.2 mul 1000 butlp
##---
##:
##: The dry undelayed signal is fed through reverbsc. Both channels of
##: reverbsc are used, so they are both equally attenuated.
##---
swap dup dup 0.97 10000 revsc 0.3 mul swap 0.3 mul
##---
##: From this point forward, the signal being treated is stereo. For this
##: reason, many stack operations are used. At the end of the day, what these
##: stack operations are doing is mixing the dry signal and delayed reverb
##: signal together.
##:
##: This is the first channel.

##---
rot dup rot add
rot rot add
##---

##: This is the second channel.

##---
rot dup rot add
rot rot add
##---

##: For now, all sporth cookbook patches are mono, so we will drop a channel.

##---
drop
##---

##: That being said, the reverb sounds very good in stereo!
##: The end.

dup
