# AudioKit 5 Migration Guide

AudioKit 5 is still in development, and in order to ensure high quality, some parts of AudioKit 4 have been removed, so the first step in migrating to AudioKit 5 is to determine whether what you used in AudioKit 4 is still available. So, first we'll start out with a list of things that are just not in AudioKit 5 in any form:

1. AudioKit 5 has an `AudioPlayer` but doesn't include the AudioKit's 4's other players `AKDiskStreamer` , `AKWaveTable`, or  `AKClipPlayer`. Some of these classes had utility and could/should be brought back to AudioKit 5.

2. The oscillator banks such as `AKOscillatorBank` and `AKMorphingOscillatorBank` have all been removed. They were coded in a way that we have since outgrown. The only polyphonic node left is `Synth` but we intend on bringing back polyphonic instruments in a well-coded way as soon as possible.

3. Inter-App Audio support has been removed. Apple has deprecated it and Audiobus now supports Apple's AUv3 format, which should work even better than Inter-App Audio.

4. `AKAudioUnitManager` was removed. A project to demonstrate this functionality has been started [here](https://github.com/AudioKit/AudioUnitManager).

5. `AKMetronome` has been removed. Its easy enough to create a metronome with `Sequencer` and one track. This will be demonstrated in the examples project.

The following items have been very significantly changed, even if their names are similar:

1. AudioKit 4's file managing class `AKAudioFile` has been removed. We have found Apple's `AVAudioFile` sufficient for this purpose now. Format conversion is now handled by AudioKit 5's `FormatConverter`.

2. AudioKit' 4's audio player `AKPlayer` and its associated `AKDynamicPlayer` and `AKAbstractPlayer` have all been removed. In its place we have `AudioPlayer` which is simpler. 

3. The following taps have been removed: `AKLazyTap`, `AKRenderTap` and `AKTimelineTap`.  We have added `PitchTap`, `RawDataTap` and `TapNode`.

Next we have things that are different but rather trivial to reimplement (and very worthwhile to do so).

1. The best way to use AudioKit 5 is to use Swift Package Manager. If you're hooked on Cocoapods, we still plan to provide Cocoapod versions, but we strongly encourage you to move to SPM. We have, and we do not regret it. 

2. `AudioKitUI` is no longer a separate framework. You can delete any imports of this. Some of the widgets that were inside of this framework have been removed entirely, but the important stuff, like waveform display, are now included in AudioKit.

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

A side effect of this change is that the syntactical sugar of setting up your chain after initialization with the syntax `oscillator >>> reverb` is gone. To dynamically change your signal chain, use a `Mixer` and its `addInput` and `removeInput` methods. This is the safest way to perform signal chain modification and works quite well.

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
Notice how ramping duration is independent for each paramter. And notice the parameter is a [property wrapper](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617) in this case, so it is prefixed by the dollar sign. Setting parameters like in the first code still works, but the changes are immediate, not ramped.

7. In addition to all parameters on AudioKit nodes (except for the ones based off of Apple DSP) being rampable, they are also automatable.  By generating piece-wise linear curves, you can approximate all kinds of ramp curves or other time varying changes to the parameters.

8. Microphone access has changed. There is no more `AKMicrophone` and instead you create a microphone as an `AudioEngine.InputNode` and instantiate on an engine you create:
```
let engine = AudioEngine()
let mic: AudioEngine.Input Node

init() {
    mic = engine.input
}
```
Also, `AKMicrophoneTracker` was removed. Using an `AudioEngine`'s `InputNode` along with a `PitchTap` is a better solution.

9. All of the projects in the Examples for have been moved out of this repository. See the [Examples](Examples.md) documentary for links to the new repositories. 



