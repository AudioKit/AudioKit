# Modulation effects

As described by Will Pirkle in his excellent book "Designing Audio Effect Plug-Ins in C++", chorus and flanger are modulated-delay effects. A short delay line is used (up to 10 ms for flanger, or 24 ms for chorus), and the delay time is modulated using a low-frequency oscillator (LFO). Feedback is always used for flanging, typically not for chorus. There is also a wet/dry mix setting, which will normally be 50/50 for flanging. Setting the mix to 100% wet (for either effect) produces vibrato.

The code here is all original; none of Pirkle's code has been used.

These are both stereo effects (stereo-in, stereo-out). The modulator LFO signals used for the left and right channels are the same frequency, but differ in phase by 90 degrees.

These effects all take up to four parameters as follows:

## `frequency`
Frequency of the modulating LFO, Hz. Acceptable range 0.1 to 10.0 Hz. For chorus and flanger, you will usually use rates less than 2 Hz. For vibrato, 5 Hz sounds good.

## `depth`
Depth of modulation, expressed as a fraction 0.0 - 1.0. The higher the number, the more pronounced the effect.

## `feedback`
Another fractional scale factor which is the amount of delayed signal which is "fed back" into the input of the delay block. For flanger (which requires at least some feedback), the acceptable range is -0.95 - +0.95; negative values mean the feedback signal is inverted. For chorus (where feedback is usually not used), the acceptable range is 0.0 - 0.25. In both cases, numbers further from zero yield more pronounced effect.

## `dryWetMix`
The effects' output is a mix of the input ("dry") signal and the delayed ("wet") signal. The *dryWetMix* value is the scale factor (always a fraction 0.0 - 1.0) for the wet signal. The scale factor for the dry signal is computed internally as 1.0 - *dryWetMix*, so they always sum to unity. The higher the *dryWetMix* value, the more pronounced the effect.


