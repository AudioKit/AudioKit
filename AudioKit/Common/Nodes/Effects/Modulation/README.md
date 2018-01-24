# Chorus and Flanger effects

As described by Will Pirkle in his excellent book "Designing Audio Effect Plug-Ins in C++", chorus and flanger are modulated-delay effects. A short delay line is used (up to 10 ms for flanger, or 24 ms for chorus), and the delay time is modulated using a low-frequency oscillator (LFO). Feedback is always used for flanging, typically not for chorus. There is also a wet/dry mix setting, which will normally be 50/50 for flanging. Setting the mix to 100% wet (for either effect) produces vibrato.

The code here is all original; none of Pirkle's code has been used.

These are both stereo effects (stereo-in, stereo-out). The modulator LFO signals used for the left and right channels are the same frequency, but differ in phase by 90 degrees.

These effects all take up to four parameters as follows:

| Name | Meaning/units | Range for Chorus | Range for Flange |
| modFreq | Modulation frequency, Hz | 0.1 - 2.0 Hz | same |
| modDepth | Modulation depth | 0.0 - 1.0 | same |
| wetFraction | Amount of wet signal | 0.1 - 1.0 | 0.5 typical |
| feedback | Feedback coefficient | 0.0 - 0.25 | -0.95 - 0.95 |
