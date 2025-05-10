# Migration Guide

## AudioKit 5.4 to 5.5

Some taps were changed to use async/await which bumped the minimum requirement operating system.

## AudioKit 5.3 to 5.4

The interface to AppleSampler was update to be more safe.

## AudioKit 5.2 to 5.3

AudioKit 5.3 is a Swift-only package, so it should be usable on iPad's Swift Playgrounds app.  To allow for this, AudioKitEX has been moved to its own package, so you will likely have to update your package dependencies to also include AudioKitEX. 


## AudioKit 5.1 to 5.2

This version update involves separating AudioKit into separate Sub-AudioKits which are included as separate Swift Packages. This way, developers do not have to compile code that their apps don't require. Most users will probably have to include the SoundpipeAudioKit package since that is the one that contained many of the oscillators, effects, and filters. In addition to including the packages, developers may also have to update their files to import the correct frameworks.

Also, please note that some types that did not move into a new *package* still moved into a new *module*. For example, `Sequencer` lives in the base AudioKit package, but code that references it will need to import the `AudioKitEX` module that is included in that package.

Here is a list of types that moved into a new package, and where they live now.

| Class                              | New Framework     |
|------------------------------------|-------------------|
| CallbackInstrument                 | [AudioKitEX](https://github.com/AudioKit/AudioKitEX)        |
| Fader                              | [AudioKitEX](https://github.com/AudioKit/AudioKitEX)        |
| StereoFieldLimiter                 | [AudioKitEX](https://github.com/AudioKit/AudioKitEX)        |
| DynaRageCompressor                 | [DevoloopAudioKit](https://github.com/AudioKit/DevoloopAudioKit/)  |
| RhinoGuitarProcessor               | [DevoloopAudioKit](https://github.com/AudioKit/DevoloopAudioKit/)  |
| Flanger                            | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| Chorus                             | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| Sampler                            | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| StereoDelay                        | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| Synth                              | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| TransientShaper                    | [DunneAudioKit](https://audiokit.io/DunneAudioKit/)      |
| DryWetMixer                        | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| BrownianNoise                      | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Drip                               | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| DynamicOscillator                  | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| FMOscillator                       | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| MetalBar                           | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| MorphingOscillator                 | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Oscillator                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PWMOscillator                      | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PhaseDistortionOscillator          | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PhaseLockedVocoder                 | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PinkNoise                          | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PluckedString                      | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| WhiteNoise                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| VocalTract                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| AmplitudeEnvelope                  | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| AutoPanner                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| AutoWah                            | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Balancer                           | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| BandPassButterworthFilter          | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| BandRejectButterworthFilter        | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| BitCrusher                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ChowningReverb                     | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Clipper                            | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| CombFilterReverb                   | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Convolution                        | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| CostelloReverb                     | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| DCBlock                            | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| DynamicRangeCompressor             | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| EqualizerFilter                    | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| FlatFrequencyResponseReverb        | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| FormantFilter                      | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| HighPassButterworthFilter          | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| HighShelfParametricEqualizerFilter | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| KorgLowPassFilter                  | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| LowPassButterworthFilter           | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| LowShelfParametricEqualizerFilter  | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ModalResonanceFilter               | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| MoogLadder                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Panner                             | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PeakingParametricEqualizerFilter   | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Phaser                             | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PitchShifter                       | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| PitchTap                           | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ResonantFilter                     | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| RolandTB303Filter                  | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| StringResonator                    | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| TanhDistortion                     | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ThreePoleLowpassFilter             | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ToneComplementFilter               | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ToneFilter                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| Tremolo                            | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| VariableDelay                      | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| ZitaReverb                         | [SoundpipeAudioKit](https://audiokit.io/SoundpipeAudioKit/) |
| OperationEffect                    | [SporthAudioKit](https://audiokit.io/SporthAudioKit/) |
| OperationGenerator                 | [SporthAudioKit](https://audiokit.io/SporthAudioKit/) |
| Clarinet                           | [STKAudioKit](https://audiokit.io/STKAudioKit/) |
| Flute                              | [STKAudioKit](https://audiokit.io/STKAudioKit/) |
| MandolinString                     | [STKAudioKit](https://audiokit.io/STKAudioKit/) |
| RhodesPiano                        | [STKAudioKit](https://audiokit.io/STKAudioKit/) |
| Shaker                             | [STKAudioKit](https://audiokit.io/STKAudioKit/) |
| TubularBells                       | [STKAudioKit](https://audiokit.io/STKAudioKit/) |

## AudioKit 5.0 to 5.1

The major change in AudioKit 5.1 is that the `Node` class was changed to be a `Node` protocol.  The parameters and parameter definition system was cleaned up as well. While these are big changes that warrant the version change, they shouldn't affect most users.

## AudioKit 4.x to 5.0

In order to ensure high quality for AudioKit 5, some parts of AudioKit 4 have been removed, so the first step in migrating to AudioKit 5 is to determine whether what you used in AudioKit 4 is still available. 

## Removed from v5

So, first we'll start out with a list of things that are just not in AudioKit 5 in any form:

1. AudioKit 5 has an `AudioPlayer` but doesn't include the AudioKit's 4's other players `AKDiskStreamer` , `AKWaveTable`, or  `AKClipPlayer`. Some of these classes had utility and could/should be brought back to AudioKit 5.

2. The oscillator banks such as `AKOscillatorBank` have all been removed. They were coded in a way that we have since outgrown. The only polyphonic node left is `Synth` but we intend on bringing back polyphonic instruments in a well-coded way as soon as possible.

3. Inter-App Audio support has been removed. Apple has deprecated it and Audiobus now supports Apple's AUv3 format, which should work even better than Inter-App Audio.

4. `AKAudioUnitManager` was removed. A project to demonstrate this functionality has been started [here](https://github.com/AudioKit/AudioUnitManager).

5. `AKMetronome` has been removed. Its easy enough to create a metronome with `Sequencer` and one track. This will be demonstrated in the Cookbook examples project.

## Significantly Changed in v5

The following items have been very significantly changed, even if their names are similar:

1. AudioKit 4's file managing class `AKAudioFile` has been removed. We have found Apple's `AVAudioFile` sufficient for this purpose now. Format conversion is now handled by AudioKit 5's `FormatConverter`.

2. AudioKit' 4's audio player `AKPlayer` and its associated `AKDynamicPlayer` and `AKAbstractPlayer` have all been removed. In its place we have `AudioPlayer` which is simpler. 

3. The following taps have been removed: `AKLazyTap`, `AKRenderTap` and `AKTimelineTap`. Instead, we have traditional AVAudioEngine style taps: `AmplitudeTap`, `PitchTap`,  and `RawDataTap`.

## Minor Changes in v5

Next we have things that are different but rather trivial to reimplement (and very worthwhile to do so).

1. The best way to use AudioKit 5 is to use Swift Package Manager. If you're hooked on Cocoapods, we still plan to provide Cocoapod versions, but we strongly encourage you to move to SPM. We have, and we do not regret it. 

2. `AudioKitUI` is now a [separate package](https://github.com/AudioKit/AudioKitUI) that has AudioKit as a dependency.

3. The AudioKit singleton no longer exists so instead of writing
```
AudioKit.output = something
AudioKit.start()
AudioKit.stop()
```
you'll need to create an instance of an AudioKit Engine:
```
let engine = AudioEngine()
engine.output = something
engine.start()
engine.stop()
```
4. AudioKit 5 drops the `AK` prefix from class names.

If you get errors like `Cannot find AKOscillator in scope` try `Oscillator` instead. If you already have defined an `Oscillator` class in your project, you can access AudioKit's oscillator with `AudioKit.Oscillator`.

5. AudioKit 5 effects no longer take optional nodes on initialization. 

In AudioKit 4 you could write `AKReverb()` but now you will have to write `Reverb(nodeYouWantToReverberate)`. One of the main reasons for this is that our audio engine is keeping track of the connections and now tightly enforces that you're not making any mistakes with dangling nodes not properly connected.  

A side effect of this change is that the syntactical sugar of setting up your chain after initialization with the syntax `oscillator >>> reverb` is gone. To change your signal chain, even while the engine is running, use a `Mixer` and its `addInput` and `removeInput` methods.

6. Ramp duration is no longer a property of AudioKit or even on AudioKit nodes. Instead, ramping parameters is much more flexible.  What used to be:
```
oscillator.rampDuration = 0.2
oscillator.amplitude = 0.9 // ramp to 0.9 over 0.2 seconds
oscillator.frequency = 880 // ramp to 880 over 0.2 seconds
```
is much more flexible:
```
oscillator.$amplitude.ramp(to: 0.9, duration: 1.2)
oscillator.$frequency.ramp(to: 880, duration: 1.7)
```
Notice how ramping duration is independent for each parameter. And notice the parameter is a [property wrapper](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617) in this case, so it is prefixed by the dollar sign. Setting parameters like in the first code still works, but the changes are immediate, not ramped.

7. In addition to all parameters on AudioKit nodes (except for the ones based off of Apple DSP) being rampable, they are also automatable.  By generating [piecewise linear](https://en.wikipedia.org/wiki/Piecewise_linear_function) curves, you can approximate all kinds of ramp curves or other time varying changes to the parameters.

8. Microphone access has changed. There is no more `AKMicrophone` and instead you create a microphone as an `AudioEngine.InputNode` and instantiate on an engine you create:
```
let engine = AudioEngine()
let mic: AudioEngine.InputNode

init() {
    mic = engine.input
}
```
Also, `AKMicrophoneTracker` was removed. Using an `AudioEngine`'s `InputNode` along with a `PitchTap` is a better solution.

9. All of the projects in the Examples for have been moved out of this repository. See the [Examples](Examples.md) documentary for links to the new repositories. 

## v4-v5 Class Name Changes

| Old Name                               | New Name                           | Notes                                                                                                                                                        |
| -------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ">>>(_:_:)"                            | -                                  | This syntactical sugar for connecting nodes has been removed.                                                                                                |
| AK3DPanner                             | -                                  | This class was never tested and seemed to not work well.                                                                                                     |
| AKADSRView                             | ADSRView                           |                                                                                                                                                              |
| AKAbstractPlayer                       | -                                  | This was a part of the AKPlayer. Use AudioPlayer instead.                                                                                                    |
| AKAmplitudeEnvelope                    | AmplitudeEnvelope                  |                                                                                                                                                              |
| AKAmplitudeTap                         | AmplitudeTap                       |                                                                                                                                                              |
| AKAmplitudeTracker                     | -                                  | Use AmplitudeTap instead.                                                                                                                                    |
| AKAppleSampler                         | AppleSampler                       |                                                                                                                                                              |
| AKAppleSequencer                       | AppleSequencer                     |                                                                                                                                                              |
| AKAudioFile                            | -                                  | Everything has been updated to use Apple's AVAudioFile. Use FormatConverter to change the format of an AVAudioFile.                                          |
| AKAudioPlayer                          | AudioPlayer                        |                                                                                                                                                              |
| AKAutoPanner                           | AutoPanner                         |                                                                                                                                                              |
| AKAutoWah                              | AutoWah                            | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKBalancer                             | Balancer                           |                                                                                                                                                              |
| AKBandPassButterworthFilter            | BandPassButterworthFilter          | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKBandRejectButterworthFilter          | BandRejectButterworthFilter        | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKBitCrusher                           | BitCrusher                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKBluetoothMIDIButton                  | BluetoothMIDIButton                |                                                                                                                                                              |
| AKBooster                              | Fader                              | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKBrownianNoise                        | BrownianNoise                      |                                                                                                                                                              |
| AKButton                               | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKBypassButton                         | -                                  |                                                                                                                                                              |
| AKCallbackInstrument                   | CallbackInstrument                 |                                                                                                                                                              |
| AKChorus                               | Chorus                             | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKChowningReverb                       | ChowningReverb                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKClarinet                             | Clarinet                           |                                                                                                                                                              |
| AKClip                                 | -                                  |                                                                                                                                                              |
| AKClipMerger                           | -                                  |                                                                                                                                                              |
| AKClipPlayer                           | -                                  |                                                                                                                                                              |
| AKClipRecorder                         | -                                  |                                                                                                                                                              |
| AKClipper                              | Clipper                            | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKCombFilterReverb                     | CombFilterReverb                   | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKComponent                            | -                                  |                                                                                                                                                               |
| AKCompressor                           | Compressor                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKComputedParameter                    | ComputedParameter                  |                                                                                                                                                              |
| AKConvolution                          | Convolution                        | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKCostelloReverb                       | CostelloReverb                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKCustomUgen                           | -                                  | Custom Ugen support has been removed from operations.                                                                                                        |
| AKDCBlock                              | DCBlock                            | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDecimator                            | Decimator                          | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDelay                                | Delay                              | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDevice                               | Device                             |                                                                                                                                                              |
| AKDiskStreamer                         | -                                  | This used a lot of AudioKit internals that were removed, but we'd love to port it to AudioKit 5 soon.                                                        |
| AKDistortion                           | Distortion                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDrip                                 | Drip                               |                                                                                                                                                              |
| AKDryWetMixer                          | DryWetMixer                        |                                                                                                                                                              |
| AKDuration                             | Duration                           |                                                                                                                                                              |
| AKDynaRageCompressor                   | DynaRageCompressor                 | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDynamicPlayer                        | -                                  | This was a part of the AKPlayer. Use AudioPlayer instead.                                                                                                    |
| AKDynamicRangeCompressor               | DynamicRangeCompressor             | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKDynamicsProcessor                    | DynamicsProcessor                  | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKEqualizerFilter                      | EqualizerFilter                    | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKExpander                             | Expander                           | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKFFTTap                               | FFTTap                             |                                                                                                                                                              |
| AKFMOscillator                         | FMOscillator                       |                                                                                                                                                              |
| AKFMOscillatorBank                     | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKFMOscillatorFilterSynth              | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKFader                                | Fader                              | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKFileClip                             | -                                  |                                                                                                                                                              |
| AKFileClipSequence                     | -                                  |                                                                                                                                                              |
| AKFlanger                              | Flanger                            | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKFlatFrequencyResponseReverb          | FlatFrequencyResponseReverb        |                                                                                                                                                              |
| AKFlute                                | Flute                              |                                                                                                                                                              |
| AKFormantFilter                        | FormantFilter                      | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKFrequencyTracker                     | -                                  | Use a PitchTap instead.                                                                                                                                      |
| AKHighPassButterworthFilter            | HighPassButterworthFilter          | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKHighPassFilter                       | HighPassFilter                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKHighShelfFilter                      | HighShelfFilter                    | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKHighShelfParametricEqualizerFilter   | HighShelfParametricEqualizerFilter | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKInput                                | -                                  | No longer necessary.                                                                                                                                         |
| AKKeyboardDelegate                     | KeyboardDelegate                   |                                                                                                                                                              |
| AKKeyboardView                         | KeyboardView                       |                                                                                                                                                              |
| AKKorgLowPassFilter                    | KorgLowPassFilter                  | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKLazyTap                              | -                                  |                                                                                                                                                              |
| AKLog(fullname:file:line:\_:)          | Log(fullname:file:line:\_:)        |                                                                                                                                                              |
| AKLowPassButterworthFilter             | LowPassButterworthFilter           | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKLowPassFilter                        | LowPassFilter                      | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKLowShelfFilter                       | LowShelfFilter                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKLowShelfParametricEqualizerFilter    | LowShelfParametricEqualizerFilter  | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKMIDI                                 | MIDI                               |                                                                                                                                                              |
| AKMIDICallback                         | MIDICallback                       |                                                                                                                                                              |
| AKMIDICallbackInstrument               | MIDICallbackInstrument             |                                                                                                                                                              |
| AKMIDIClockListener                    | MIDIClockListener                  |                                                                                                                                                              |
| AKMIDIControl                          | MIDIControl                        |                                                                                                                                                              |
| AKMIDIEvent                            | MIDIEvent                          |                                                                                                                                                              |
| AKMIDIFile                             | MIDIFile                           |                                                                                                                                                              |
| AKMIDIFileChunkEvent                   | MIDIFileChunkEvent                 |                                                                                                                                                              |
| AKMIDIFileTrack                        | MIDIFileTrack                      |                                                                                                                                                              |
| AKMIDIInstrument                       | MIDIInstrument                     |                                                                                                                                                              |
| AKMIDIListener                         | MIDIListener                       |                                                                                                                                                              |
| AKMIDIMetaEvent                        | MIDIMetaEvent                      |                                                                                                                                                              |
| AKMIDIMetaEventType                    | MIDIMetaEventType                  |                                                                                                                                                              |
| AKMIDIMonoPolyListener                 | MIDIMonoPolyListener               |                                                                                                                                                              |
| AKMIDINode                             | MIDINode                           |                                                                                                                                                              |
| AKMIDINoteData                         | MIDINoteData                       |                                                                                                                                                              |
| AKMIDIOMNIListener                     | MIDIOMNIListener                   |                                                                                                                                                              |
| AKMIDISampler                          | MIDISampler                        |                                                                                                                                                              |
| AKMIDIStatus                           | MIDIStatus                         |                                                                                                                                                              |
| AKMIDIStatusType                       | MIDIStatusType                     |                                                                                                                                                              |
| AKMIDISystemCommand                    | MIDISystemCommand                  |                                                                                                                                                              |
| AKMIDISystemCommandType                | MIDISystemCommandType              |                                                                                                                                                              |
| AKMIDISystemRealTimeListener           | MIDISystemRealTimeListener         |                                                                                                                                                              |
| AKMIDITempoListener                    | MIDITempoListener                  |                                                                                                                                                              |
| AKMIDITimeOut                          | MIDITimeOut                        |                                                                                                                                                              |
| AKMIDITransformer                      | MIDITransformer                    |                                                                                                                                                              |
| AKManager                              | -                                  | This was a global singleton, instead create an instance of AudioEngine.                                                                                      |
| AKMandolin                             | MandolinString                     | This no longer simulataes for 4 sets of 2 strings, but rather just one string. Combine as necessary in your own code.                                        |
| AKMetalBar                             | MetalBar                           |                                                                                                                                                              |
| AKMetronome                            | -                                  | Use a Sequencer with a metronome track instead.                                                                                                              |
| AKMicrophone                           | -                                  | Use AudioEngine.InputNode, or engine.input.                                                                                                                  |
| AKMicrophoneTracker                    | -                                  | Use AmplitudeTap and Pitch Tap instead.                                                                                                                      |
| AKMixer                                | Mixer                              | Mixer now has addInput and removeInput which can be used to dynamically change the signal chain while the engine is running.                                 |
| AKModalResonanceFilter                 | ModalResonanceFilter               | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKMoogLadder                           | MoogLadder                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKMorphingOscillator                   | MorphingOscillator                 |                                                                                                                                                              |
| AKMorphingOscillatorBank               | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKMorphingOscillatorFilterSynth        | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKMusicTrack                           | MusicTrackManager                  |                                                                                                                                                              |
| AKNode                                 | Node                               |                                                                                                                                                              |
| AKNodeFFTPlot                          | NodeFFTPlot                        |                                                                                                                                                              |
| AKNodeOutputPlot                       | NodeOutputPlot                     |                                                                                                                                                              |
| AKNodeRecorder                         | NodeRecorder                       |                                                                                                                                                              |
| AKOperation                            | Operation                          |                                                                                                                                                              |
| AKOperationEffect                      | OperationEffect                    |                                                                                                                                                              |
| AKOperationGenerator                   | OperationGenerator                 |                                                                                                                                                              |
| AKOscillator                           | Oscillator                         |                                                                                                                                                              |
| AKOscillatorBank                       | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKOscillatorFilterSynth                | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKOutput                               | -                                  | No longer necessary.                                                                                                                                         |
| AKOutputWaveformPlot                   | -                                  | Use a plot attached to a node.                                                                                                                               |
| AKPWMOscillator                        | PWMOscillator                      |                                                                                                                                                              |
| AKPWMOscillatorBank                    | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPWMOscillatorFilterSynth             | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPanner                               | Panner                             |                                                                                                                                                              |
| AKParameter                            | Parameter                          |                                                                                                                                                              |
| AKPeakLimiter                          | PeakLimiter                        |                                                                                                                                                              |
| AKPeakingParametricEqualizerFilter     | PeakingParametricEqualizerFilter   |                                                                                                                                                              |
| AKPeriodicFunction                     | -                                  | Can use a Callback Loop or a Timer instead.                                                                                                                  |
| AKPhaseDistortionOscillator            | PhaseDistortionOscillator          |                                                                                                                                                              |
| AKPhaseDistortionOscillatorBank        | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPhaseDistortionOscillatorFilterSynth | -                                  | This used a lot of AudioKit internals that were removed. You can use Synth for polyphonic sounds, and we hope to reintroduce polyphonic banks into AK5 soon. |
| AKPhaseLockedVocoder                   | PhaseLockedVocoder                 | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKPhaser                               | Phaser                             | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKPinkNoise                            | PinkNoise                          |                                                                                                                                                              |
| AKPitchShifter                         | PitchShifter                       | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKPlayer                               | AudioPlayer                        | AudioPlayer is a major simplification of AKPlayer and is currently much more restrictive on what you can do with it.                                         |
| AKPlaygroundLoop                       | CallbackLoop                       |                                                                                                                                                              |
| AKPlaygroundView                       | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKPluckedString                        | PluckedString                      |                                                                                                                                                              |
| AKPolyphonic                           | Polyphonic                         |                                                                                                                                                              |
| AKPolyphonicNode                       | PolyphonicNode                     |                                                                                                                                                              |
| AKPresetLoaderView                     | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKPropertySlider                       | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKRawMIDIPacket                        | RawMIDIPacket                      |                                                                                                                                                              |
| AKRecordingResult                      | -                                  |                                                                                                                                                              |
| AKRenderTap                            | -                                  |                                                                                                                                                              |
| AKResonantFilter                       | ResonantFilter                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKResourcesAudioFileLoaderView         | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKReverb                               | Reverb                             | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKReverb2                              | -                                  | Errored in AudioKit 5 on  initialization. Could be resurrected by someone interested in doing so.                                                            |
| AKRhinoGuitarProcessor                 | RhinoGuitarProcessor               | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKRhodesPiano                          | RhodesPiano                        |                                                                                                                                                              |
| AKRingModulator                        | RingModulator                      | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKRolandTB303Filter                    | RolandTB303Filter                  | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKRollingOutputPlot                    | -                                  | Use a plot attached to a node.                                                                                                                               |
| AKSamplePlayer                         | SamplePlayer                       |                                                                                                                                                              |
| AKSampler                              | Sampler                            |                                                                                                                                                              |
| AKSequencer                            | Sequencer                          |                                                                                                                                                              |
| AKSequencerTrack                       | SequencerTrack                     |                                                                                                                                                              |
| AKSettings                             | Settings                           |                                                                                                                                                              |
| AKShaker                               | Shaker                             |                                                                                                                                                              |
| AKShakerType                           | ShakerType                         |                                                                                                                                                              |
| AKStepper                              | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKStereoDelay                          | StereoDelay                        |                                                                                                                                                              |
| AKStereoFieldLimiter                   | StereoFieldLimiter                 |                                                                                                                                                              |
| AKStereoInput                          | StereoInput                        |                                                                                                                                                              |
| AKStereoOperation                      | StereoOperation                    |                                                                                                                                                              |
| AKStringResonator                      | StringResonator                    | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKSynth                                | Synth                              |                                                                                                                                                              |
| AKSynthKick                            | SynthKick                          |                                                                                                                                                              |
| AKSynthSnare                           | SynthSnare                         |                                                                                                                                                              |
| AKTable                                | Table                              |                                                                                                                                                              |
| AKTableType                            | TableType                          |                                                                                                                                                              |
| AKTanhDistortion                       | TanhDistortion                     | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKTelephoneView                        | -                                  | We have removed most of UI elements that were not specific to audio.                                                                                         |
| AKTester                               | -                                  | AudioEngine now has the testing functionality                                                                                                                |
| AKThreePoleLowpassFilter               | ThreePoleLowpassFilter             |                                                                                                                                                              |
| AKTimePitch                            | TimePitch                          | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKTimelineTap                          | -                                  |                                                                                                                                                              |
| AKTiming                               | -                                  |                                                                                                                                                              |
| AKToggleable                           | Toggleable                         |                                                                                                                                                              |
| AKToneComplementFilter                 | ToneComplementFilter               | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKToneFilter                           | ToneFilter                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKTremolo                              | Tremolo                            |                                                                                                                                                              |
| AKTry(\_:)                             | ExceptionCatcher(\_:)              |                                                                                                                                                              |
| AKTubularBells                         | TubularBells                       |                                                                                                                                                              |
| AKTuningTable                          | TuningTable                        |                                                                                                                                                              |
| AKTuningTableBase                      | TuningTableBase                    |                                                                                                                                                              |
| AKTuningTableDelta12ET                 | TuningTableDelta12ET               |                                                                                                                                                              |
| AKTuningTableETNN                      | TuningTableETNN                    |                                                                                                                                                              |
| AKVariSpeed                            | VariSpeed                          | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKVariableDelay                        | VariableDelay                      | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AKVocalTract                           | VocalTract                         |                                                                                                                                                              |
| AKWaveTable                            | -                                  | This used a lot of AudioKit internals that were removed, but we'd love to port it to AudioKit 5 soon.                                                        |
| AKWhiteNoise                           | WhiteNoise                         |                                                                                                                                                              |
| AKZitaReverb                           | ZitaReverb                         | All effects need an input. ie. no more empty initialzers with connections defined later.                                                                     |
| AudioKit                               | -                                  | This was a global singleton, instead create an instance of AudioEngine.                                                                                      |
| AudioKitUI                             | -                                  | [Separate package](https://github.com/AudioKit/AudioKitUI)                                                                                                 |
| ClipMergeDelegate                      | -                                  | Original programmer hired by Apple and not available for maintaining.                                                                                        |
| ClipMergerError                        | -                                  | Original programmer hired by Apple and not available for maintaining.                                                                                        |
| ClipRecordingError                     | -                                  | Original programmer hired by Apple and not available for maintaining.                                                                                        |
| FileClip                               | -                                  | Original programmer hired by Apple and not available for maintaining.                                                                                        |
| MultitouchGestureRecognizer            | MultitouchGestureRecognizer        |                                                                                       |
| random(_:_:)                           | -                                  | Use AUValue's random(in:) method.                                                                                                                            |

