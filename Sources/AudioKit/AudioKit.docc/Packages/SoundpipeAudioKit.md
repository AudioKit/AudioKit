# Soundpipe AudioKit

Many oscillators, physical models, effects, and filters for AudioKit. 

## Installation in Xcode 13

You can AudioKit and any of the other AudioKit libraries using Collections

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://swiftpackageindex.com/AudioKit/collection.json` as the URL and click the "Load" button.
5. It will warn you that the collection is not signed, but it is fine, click "Add Unsigned Collection".
6. Now you can add any of the AudioKit Swift Packages you need and read about what they do, right from within Xcode.

## Targets

| Name               | Description                                                 | Language      |
|--------------------|-------------------------------------------------------------|---------------|
| SoundpipeAudioKit  | API for using Soundpipe-powered Audio Units                 | Swift         |
| CSoundpipeAudioKit | Audio Units for the Soundpipe DSP                           | Objective-C++ |
| Soundpipe          | Low-level DSP for oscillators, physical models, and effects | C             |

## Generators / Instruments

* [Brownian Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/browniannoise)
* [Drip](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/drip)
* [Dynamic Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dynamicoscillator)
* [FM Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/fmoscillator)
* [Metal Bar](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/metalbar)
* [Morphing Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/morphingoscillator)
* [Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/oscillator)
* [PWM Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pwmoscillator)
* [Phase Distortion Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phasedistortionoscillator)
* [Phase Locked Vocoder](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phaselockedvocoder)
* [Pink Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pinknoise)
* [Plucked String](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pluckedstring)
* [White Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/whitenoise)
* [Vocal Tract](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/vocaltract)

## Effects / Filters

* [Amplitude Envelope](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/amplitudeenvelope)
* [Auto Panner](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/autopanner)
* [Auto Wah](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/autowah)
* [Balancer](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/balancer)
* [Band Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bandpassbutterworthfilter)
* [Band Reject Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bandrejectbutterworthfilter)
* [Bit Crusher](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bitcrusher)
* [Chowning Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/chowningreverb)
* [Clipper](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/clipper)
* [CombFilter Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/combfilterreverb)
* [Convolution](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/convolution)
* [Costello Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/costelloreverb)
* [DC Block](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dcblock)
* [Dynamic Range Compressor](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dynamicrangecompressor)
* [Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/equalizerfilter)
* [Flat Frequency ResponseReverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/flatfrequencyresponsereverb)
* [Formant Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/formantfilter)
* [High Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/highpassbutterworthfilter)
* [High Shelf Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/highshelfparametricequalizerfilter)
* [Korg Low Pass Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/korglowpassfilter)
* [Low Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/lowpassbutterworthfilter)
* [Low Shelf Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/lowshelfparametricequalizerfilter)
* [Modal Resonance Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/modalresonancefilter)
* [Moog Ladder](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/moogladder)
* [Panner](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/panner)
* [Peaking Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/peakingparametricequalizerfilter)
* [Phaser](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phaser)
* [Pitch Shifter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pitchshifter)
* [Resonant Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/resonantfilter)
* [Roland TB303 Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/rolandtb303filter)
* [String Resonator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/stringresonator)
* [Tanh Distortion](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tanhdistortion)
* [Three Pole Lowpass Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/threepolelowpassfilter)
* [Tone Complement Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tonecomplementfilter)
* [Tone Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tonefilter)
* [Tremolo](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tremolo)
* [Variable Delay](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/variabledelay)
* [Zita Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/zitareverb)
