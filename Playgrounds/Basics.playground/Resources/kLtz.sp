##: # kLtz
##: kLtz is a patch I wrote for Aure demonstrating one way I use
##: **smoothdelay**, a variable delay line that does not have pitch modulation.
##: The name is inspired by titles from artists like Aphex Twin and Autechre.
##: After creating the initial patch, I then added control sliders, which
##: ended up adding a lot of dimension.
##:
##: The controls of the patch are the following:
##:
##: - Control 1: tempo
# default 0.66147
##: - Control 2: probability
# default 0.6299
##: - Control 3: feedback
# default 0.7244
##: - Control 4: resonance
# default 0.4645
##:

##:
##: ## Clock
##:

##: As usual, the patch starts off with setting up the clock.
##:
##: First, a 1-size ftable called *trig* is created for storing the
##: clock signal.

##---
_trig 1 zeros
##---

##: **dmetro** is the main clock source. The BPM is decided from p-register
##: 0, and multiplied by 4 to make the clock sixteenth notes. **bpm2dur**
##: converts the bpm to a duration in seconds to make it a suitable
##: parameter for **dmetro**.

##---
0 p 60 155 scale 4 * bpm2dur dmetro
##---

##: The output of **dmetro** is fed into a maytrig, whose probability is
##: controlled by p-register 1.

##---
1 p 0.2 1 scale maytrig
##---

##: From there, the signal is set to the table *trig* via **tset**.
##: Prior to that it is
##: duplicated so that the clock signal also remains on the stack.

##---
dup 0 _trig tset
##---

##:
##: ## Envelope
##:

##: The clock signal generated from the previous section triggers an
##: exponential envelope. The attack and hold parameters are constants.

##---
0.0001 0.004
##---

##: The final parameter is the release time.
##: The release time is randomly generated with the sample and hold generater
##: **randh**, picking release times between 1 and 30 milliseconds.

##---
0.001 0.03 10 randh tenvx
##---

##:
##: ## Filtered Noise
##:

##: The noise is multiplied by the envelope generator.

##---
0.5 noise *
##---

##: The cutoff frequency of the filter is controlled by a random line generator
##: generating values between 500 and 4000. The rate of the random line is
##: determined by p-register 3.

##---
500 4000 3 p 3 40 scale randi
##---

##: The resononace of the filter is also determined by p-register 3.
##: This particular filter design has a resonance range of 0 to 2.
##: This high resonance amount causes a lot of self oscillations. This is what
##: causes the sinusoidal sounds.

##---
3 p 1.7 1.9 scale
##---

##: The last parameter of **wpkorg35** is distortion amount.

##---
1.11 wpkorg35
##---

##:
##: ## Smooth Delay
##:

##: **smoothdelay** is a double delay line that linearly interpolates
##: them any time the delay time changes. This causes a delay line that
##: can smoothly change delay times. Hence, the name.
##:

##: The input signal is duplicated, one being sent into the delay line.
##: The feedback of the delay line is determined by p-register 2.

##---
dup 2 p 0.1 0.99 scale
##---

##: The clock signal is obtained from the table *trig*, and sent into a
##: clock divider, turning the sixteenth notes into quarter notes.

##---
0 _trig tget 4 0 tdiv
##---

##: This signal triggers the triggerable random number genrator **trand**.
##: The value of **trand** determines the delay time of **smoothdelay**.

##---
0.001 0.29 trand
##---

##: The maximum delay time and the interpolation time (in samples) are the
##: final parameters to **smoothdelay**. Is is then scaled and added to
##: the dry signal.

##---
0.4 1024 smoothdelay 0.3 * +
##---

dup
