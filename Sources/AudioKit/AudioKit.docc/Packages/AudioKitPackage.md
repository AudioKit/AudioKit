# AudioKit Package

## Installation

Use Swift Package Manager and point to the URL:  [https://github.com/AudioKit/AudioKit/](https://github.com/AudioKit/AudioKit/)

## Github Wiki 

AudioKit's inline comments are processed by [SwiftDoc](https://github.com/SwiftDocOrg/swift-doc) and automatically create documentation on [AudioKit's Github Wiki](https://github.com/AudioKit/AudioKit/wiki).

## Targets

| Name        | Description                                                      | Language      |
|-------------|------------------------------------------------------------------|---------------|
| AudioKit    | Wrappers for AVFoundation Effects                                | Swift         |
| AudioKitEX  | Nodes, Parameters, Automation, Sequencing                        | Swift         |
| CAudioKitEX | DSP and other low level code supporting AudioKitEX functionality | Objective-C++ |

## Nodes

Nodes are interconnectable components that work with the audio stream. For a node to work, audio has to be pulled through it. For audio to be pulled through a node, the audio signal chain that includes the node has to eventually reach an output. 

AudioKit has several kinds of nodes:

### Analysis 

These nodes do not change the audio at all.  They examine the audio stream and extract information about the stream.  For example, the two most common uses for this are determining the audio's pitch and loudness.

### Effects

These nodes do change the audio stream.  They require an input to process.

### Generators

Generators create audio signal from scratch and as such they do not require an input signal.

### Input 

Like generator nodes, input nodes create audio, but in this case the audio that is create is retrieved from an input like a microphone or another app's output.

### Mixing

These nodes are about managing more than one sound simultaneously. Sounds can be combined, placed spatially, have their volumes changed, etc.

### Offline Rendering

This is for processing an audio quickly and saving it, rather than playing it in realtime through a speaker.

### Playback

Playback nodes are about playing and working with audio files.  We also include metronome nodes here.

## Format Converter

FormatConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
```swift
let options = FormatConverter.Options()
// any options left nil will assume the value of the input file
options.format = "wav"
options.sampleRate = 48000
options.bitDepth = 24

let converter = FormatConverter(inputURL: oldURL, outputURL: newURL, options: options)
converter.start { error in
// check to see if error isn't nil, otherwise you're good
})
```

## MIDI

AudioKit MIDI is an implementation of CoreMIDI meant to simplify creating and responding to MIDI signals. 

Add MIDI listeners like this:
 ```
var midi = MIDI()
midi.openInput()
midi.addListener(someClass)
 ```
 ...where `someClass` conforms to the `MIDIListener` protocol

You then implement the methods you need from `MIDIListener` and use the data how you need.


## Tables

Tables are just arrays of float data. They are most often used to store waveform data and they have some defaults for the most common cases:

* sine wave
* triangle wave
* square wave
* sawtooth wave
* reverse sawtooth wave
* positive sine
* positive triangle
* positive square
* positive sawtooth
* positive reverse sawtooth

Tables can also store audio or control data.

## Sequencing

The `AppleSequencer` is based on tried-and-true CoreAudio/MIDI sequencing.

## Taps

Taps are a way to get access to the audio stream at a given point in the signal chain without 
inserting a node into the signal chain, but instead sort of syphoning off audio "tapping" it and using
the data for some side purpose like plotting or running analysis of the stream at that point.

## Samplers

The term "sampler" is a bit misleading. Originally, it referred to a hardware device capable of recording ("sampling") sound and then re-playing it from a keyboard. In practice, the playback aspect proved to be far more popular then the recording aspect, and today the two functions are nearly always completely separated. What we call a "sampler" today is simply a system for replaying previously-prepared sounds ("samples").

### AppleSampler and MIDISampler

**NOTE:** In earlier versions of AudioKit, **AppleSampler** was called **Sampler**.

Apple's *AUSampler* Audio Unit, despite a few unfortunate flaws, is exceptionally powerful, and has served as the basis for countless sample-based iOS music apps. It has five huge advantages over the other two sampler modules:

1. *Streaming:* AUSampler plays sample data directly from files; it is not necessary to pre-load samples into memory.
2. AUSampler is *polytimbral:* Sounds can be defined using multiple *layers*, so each note can involve multiple samples played back in different combinations. Each layer can optionally include a low-pass filter with resonance, one or more envelope generators, and one or more LFOs for modulation.
3. It features a *modular architecture*, where the number and interconnection of sample oscillators and LFOs in each layer can be defined dynamically, expressed in a "metadata" file.
4. It can *import multiple metadata file formats*, which describe how whole sets of samples are mapped across the MIDI keyboard and affected by MIDI key velocity, together with layer structures, modulation, etc.
5. The Mac version can be loaded as a plug-in into a DAW such as *Logic Pro X*, and includes a GUI for defining layer structures, modulation and real-time MIDI control, and the mapping of MIDI note/velocity to samples.

Unfortunately, *AUSampler* has some fatal flaws, and indeed appears to be an unfinished project. Using it as a plug-in on the Mac, to develop sample-based instruments (sample sets + metadata) tends to be an exercise in frustration. It can crash the DAW. Using AUSamplers plug-in in a DAW gives a GUI which is supposed to be able to read [SoundFont](https://www.lifewire.com/sfz-file-2622282), DLS and EXS24 metadata files, but in practice rarely does so perfectly. Its native `.aupreset` metadata format, which is a [Property List](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html), is undocumented and confusing. The  `.aupreset` can be edited within Xcode Property List editor. After converting a EXS24 or before deploying to iOS usually the paths need to be manually fixed. See [Apple Technical Note TN2283](https://developer.apple.com/library/content/technotes/tn2283/_index.html). The  `.aupreset` can also be programmatically edited using **PresetManager** and **PresetBuilder**. [External example in StackOverflow](https://stackoverflow.com/questions/47359088/playing-multi-sampled-instruments-using-audiokit-controlling-adsr-envelope/47370008#47370008).

The AudioKit class **AppleSampler** basically just wraps an instance of *AUsampler* and makes its Objective-C based API accessible from Swift. Most music apps use the higher-level **MIDISampler** class, whose `enableMIDI()` function connects it directly to the stream of incoming MIDI data.

## Apple Sampler Notes

### Making AppleSampler not get corrupted by an audio route change 

When the audio session route changes (the iOS device is plugged into an external sound interface, headphones are connected, you start capturing a video on a mac using Quicktime...) Samplers start producing distorted audio.

Registering for audio route changes is simple and doesn't require anything from the basic app flow like the delegate or view controllers. Just do:

```
NotificationCenter.default.addObserver(self, selector: #selector(routeChanged), name: .AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
```

Define the event handler:

```
@objc func routeChanged(_ notification: Notification) {
    Log("Audio route changed")
    
    AudioKit.stop() // Note 1

    do {
        try sampler.loadEXS24(yourSounds) // Note 2
    } catch  {
        Log("could not load samples")
    }

    AudioKit.start()
}
```

Note 1: Sometimes stopping and starting AudioKit is not necessary. I suspect that this has something to do with sampling rates and bit rates, but I didn't investigate further, because I needed to support the stricter case anyway

Note 2: Samplers need to reload. AudioKit could implement route tracking in the main singleton, register all samplers and do this automatically to work properly out of the box.
