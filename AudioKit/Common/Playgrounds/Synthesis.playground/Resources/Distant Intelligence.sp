##: # Distant Intelligence

##: This is a sporthling I made with the intention of being used inside of
##: the Sporth editor in AudioKit. For this reason, the patch has four
##: external controls, represented as the first 4 p-registers. They are
##: as follows:
##: - Control 1: Pitch
##: - Control 2: Tempo
##: - Control 3: FM Brightness
##: - Control 4: FM Detune
##:
##: ## Table generation

##: First begin by generating a sequence called *seq*.
##: These are the midi note numbers of the scale used.
##---
_seq '67 69 71 72 74 76' gen_vals
##---

##: P-registers are being used by an external program, so we create an argument
##: table called "args".

##---
_args 4 zeros
##---

##: P-register 4 is not being used, so this is set to be the frequency of
##: the C above middle C (midi note 72).
##: This will be used as the base frequency for "gen\\_padsynth".

##---
72 mtof 4 pset
##---

##: This table generated contains the amplitudes for partials, need for padsynth.

##---
_amps '1.0 0.5 0.25 0.5' gen_vals
##---

##: Finally, the padsynth wavetable is generated.

##---
_pad 262144 4 p 40 'amps' gen_padsynth
##---

##:
##: ## Clock
##:

##: The clock of the patch is set with a dmetro, whose value is set by
##: p-register 1. It is scaled to be 40 to 200 BPM, then multiplied
##: by four to represent sixteenth notes. This value is converted to
##: a duration before being sent to dmetro.

##---
1 p 40 200 scale 4 * bpm2dur dmetro
##---

##: This steady dmetro clock is sent into a maytrig, where a trigger has a
##: 60 percent chance of reaching the other side of the maytrig. It is duplicated
##: and set to the first value of table *args*.

##---
0.6 maytrig dup 0 _args tset
##---


##:
##: ## FM
##:

##: This patch contains a single FM oscillator.

##: The exponential envelope created has a 2ms attack, 4ms hold, and a 200ms
##: release time. The trigger for it is from the maygated dmetro, currently
##: on the stack.  This pushes an envelope onto the stack. Remember this...

##---
0.002 0.004 0.2 tenvx
##---

##: Now comes paramters for the FM oscillator itself, starting with frequency.
##: p-register zero ultimately picks the frequency that the oscillator should
##: play. It picks one of 4 values, which is sent to *tget*. The values are
##: floored to truncate any fractional components.

##---
0 p 0 4 scale floor _seq tget
##---

##: Some portamento is added to gliss between the selected notes.

##---
0.1 port
##---

##: Now the midi note values get converted to frequencies...

##---
mtof
##---

##: We save this frequency to index 2 of the *args* table to be used later on.

##---
dup 2 _args tset
##---

##: The amplitude of the FM oscillator is 0.2
##: The carrier ratio is 1.

##---
0.2 1
##---

##: Onto the modulator ratio now.
##: The clock signal is taken from index 0 of the table *args*, and this feeds
##: into *trand*, producing floating point values between 0 and 5. We then
##: duplicate this value and truncate the fractional part with floor. We then
##: use p-register 3 to crossfade between the values.

##---
0 _args tget 0 5 trand dup floor 3 p cf
##---

##: An integer modulator value will create harmonic partials, while a fraction
##: value will create a more clangorous sound. The crossfade controls the amount
##: of "bite" it will have.
##:
##: Finally, p-register 2 controls the modulation index, which essentially
##: determines the brightness. The control signal is put through a portamento
##: filter with a very long time, so only gradual changes are possible.
##:
##: After this, the FM oscillator is multiplied with the exponetial envelope.
##---
2 p 0.5 port 0 3 scale
fm *
##---

##:
##: ## Padsynth
##:

##: There are two wavetable oscillators which utilize the Padsynth algorithm
##: by Nasca Octavian Paul.
##:
##: Due to the nature of the wavetable, the frequency portion of the
##: oscillator needs special treatment. An oscillator of 1 Hz has frequency
##: of C above middle C (midi number 72), so any other frequency must be
##: relative to that (2 Hz, for instance, would be an octave higher, 0.5 hz
##: an octave lower).
##:
##: The frequency of the FM oscillator from before is extracted from index 2
##: of the table called *args*, and is divided by the base frequency set to
##: p register 4. This gives us our relative frequency.
##---
2 _args tget 4 p /
##---

##: The rest of the arguments are pretty typical parameters to oscillator:
##: amplitude, phase, and table name. The oscillator is added with the FM
##: oscillator.

##---
0.1 0 _pad osc +
##---

##: The process is repeated again for our second oscillator,
##: only we give it a frequency 1.5 times that of the FM oscillator, giving us
##: a perfect fifth above. This oscillator is then added into the mix.

##---
2 _args tget 1.5 * 4 p / 0.1 0 _pad osc +
##---

##:
##: ## Effects
##:

##: The only effect use here is a reverb. This reverb algorithm is the
##: zitareverb algorithm. The unit generator here is a simplified version
##: of the reverb generator with less parameters.

##---
dup dup 5 8 3000 zrev drop 0.3 * +
##---

dup
