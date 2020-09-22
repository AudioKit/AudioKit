# AudioKit 5 Migration Guide

1. The best way to use AudioKit 5 is to use Swift Package Manager. If you're hooked on Cocoapods, we still plan to provide Cocoapod versions, but we strongly encourage you to move to SPM. We have, and we do not regret it. 

2. The AudioKit singleton no longer exists so instead of writing
```
AudioKit.output = something
AudioKit.start()
AudioKit.stop()
```
you'll need to create an instead of an AudioKit Engine:
```
let engine = AudioEngine()
engine.output = something
engine.start()
engine.stop()
```
3. AudioKit 5 drops the `AK` prefix from class names.

If you get errors like `Cannot find AKOscillator in scope` try `Oscillator` instead. If you already have defined an `Oscillator` class in your project, you can access AudioKit's oscillator with `AudioKit.Oscillator`.

4. AudioKit 5 effects no longer take optional nodes on initialization. 

In AudfioKit 4 you could write `AKReverb()` but now you will have to write `Reverb(nodeYouWantToReverberate)`. One of the main reasons for this is that our audio engine is keeping track of the connections and now tightly enforces that you're not making any mistakes with dangling nodes not properly connected.  

A side effect of this change is that the syntactical sugar of setting up your chain after initialization with the syntax `oscillator >>> reverb` is gone. To dynamically change your signal chain, use a `Mixer` and its `addInput` and `removeInput` methods. This is the safest way to signal chain modification and works quite well.

5. Ramp duration is no longer a property of AudioKit or even on AudioKit nodes. Instead, ramping parameters is much more flexible.  What used to be:
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
Notice how ramping duration is independent for each paramter. And notice the parameter is a property wrapper in this case, so it is prefixed by the dollar sign. Setting parameters like in the first code still works, but the changes are immediate, not ramped.

6. In addition to all parameters on AudioKit noes (except for the ones based off of Apple DSP) being rampable, they are also automatable.  By generating piece-wise linear curves, you can approximate all kinds of ramp curves or other time varying changes to the parameters.

7. Microphone access has changed. There is no more `AKMicrophone` and instead you create a microphone as an `AudioEngine.InputNode` and instantiate on an engine you create:
```
let engine = AudioEngine()
let mic: AudioEngine.Input Node

init() {
mic = engine.input
}
```

8. AudioKit 4's file managing class `AKAudioFile` has been removed. We have found Apple's `AVAudioFile` sufficient for this purpose now. Format conversion is now handled by AudioKit 5's `FormatConverter`.

9. AudioKit' 4's audio player `AKPlayer` and its associated `AKDynamicPlayer` and `AKAbstractPlayer` have all been removed. In its place we have `AudioPlayer` which is simpler. 

10. AudioKit's 4's other two players `AKDiskStreamer` and `AKWaveTable` have been removed. These classes should reappear in updates to Verison 5.

11. The oscillator banks such as `AKOscillatorBank` and `AKMorphingOscillatorBank` have all been removed. They were coded in a way that we have since outgrown. The only polyphonic node left is `Synth` but we intend on bringing back polyphonic instruments in a well-coded way as soon as possible.

12. All of the projects in the Examples for have been moved out of this repository. See the [Examples](Examples.md) documentary for links to the new repositories. 



