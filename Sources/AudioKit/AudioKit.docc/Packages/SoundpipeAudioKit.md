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

* [Brownian Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BrownianNoise)
* [Drip](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Drip)
* [Dynamic Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DynamicOscillator)
* [FM Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FMOscillator)
* [Metal Bar](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MetalBar)
* [Morphing Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MorphingOscillator)
* [Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Oscillator)
* [PWM Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PWMOscillator)
* [Phase Distortion Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PhaseDistortionOscillator)
* [Phase Locked Vocoder](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PhaseLockedVocoder)
* [Pink Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PinkNoise)
* [Plucked String](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PluckedString)
* [White Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/WhiteNoise)
* [Vocal Tract](https://github.com/AudioKit/SoundpipeAudioKit/wiki/VocalTract)

## Effects / Filters

* [Amplitude Envelope](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AmplitudeEnvelope)
* [Auto Panner](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AutoPanner)
* [Auto Wah](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AutoWah)
* [Balancer](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Balancer)
* [Band Pass Butterworth Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BandPassButterworthFilter)
* [Band Reject Butterworth Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BandRejectButterworthFilter)
* [Bit Crusher](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BitCrusher)
* [Chowning Reverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ChowningReverb)
* [Clipper](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Clipper)
* [CombFilter Reverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/CombFilterReverb)
* [Convolution](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Convolution)
* [Costello Reverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/CostelloReverb)
* [DC Block](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DCBlock)
* [Dynamic Range Compressor](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DynamicRangeCompressor)
* [Equalizer Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/EqualizerFilter)
* [Flat Frequency ResponseReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FlatFrequencyResponseReverb)
* [Formant Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FormantFilter)
* [High Pass Butterworth Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/HighPassButterworthFilter)
* [High Shelf Parametric Equalizer Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/HighShelfParametricEqualizerFilter)
* [Korg Low Pass Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/KorgLowPassFilter)
* [Low Pass Butterworth Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/LowPassButterworthFilter)
* [Low Shelf Parametric Equalizer Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/LowShelfParametricEqualizerFilter)
* [Modal Resonance Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ModalResonanceFilter)
* [Moog Ladder](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MoogLadder)
* [Panner](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Panner)
* [Peaking Parametric Equalizer Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PeakingParametricEqualizerFilter)
* [Phaser](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Phaser)
* [Pitch Shifter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PitchShifter)
* [Resonant Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ResonantFilter)
* [Roland TB303 Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/RolandTB303Filter)
* [String Resonator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/StringResonator)
* [Tanh Distortion](https://github.com/AudioKit/SoundpipeAudioKit/wiki/TanhDistortion)
* [Three Pole Lowpass Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ThreePoleLowpassFilter)
* [Tone Complement Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ToneComplementFilter)
* [Tone Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ToneFilter)
* [Tremolo](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Tremolo)
* [Variable Delay](https://github.com/AudioKit/SoundpipeAudioKit/wiki/VariableDelay)
* [Zita Reverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ZitaReverb)
