<div align=center>
<img src="https://github.com/AudioKit/Cookbook/raw/main/Cookbook/Cookbook/Assets.xcassets/audiokit-icon.imageset/audiokit-icon.png" width="20%"/>
</div>

# What is AudioKit?

AudioKit is an entire audio development ecosystem of code repositories, packages, libraries, algorithms, applications, playgorunds, tests, and scripts, built and used by a community of audio programmers, app developers, engineers, researchers, scientists, musicians, gamers, and people new to programming.

AudioKit has several underlying goals that motivate its development.

1. First, we hope that learning to program with AudioKit is easy for anybody. In order to get people started we provide Swift Playgrounds, demonstration applications, and access to a supportive Slack group of AudioKit Professionals.

2. Next, we want AudioKit to be extensible to allow more advanced developers to create their own custom apps and libraries built on top of AudioKit. Most of what used to be part of AudioKit has been moved to separate packages to ensure AudioKit is extensible and to give developers several examples of different approaches to extending AudioKit.

3. An important goal for AudioKit is to allow it to grow and be maintainable by a handful of volunteers. For this reason we have extensive tests that are run whenever changes are made to any AudioKit code repository. We accept and encourage Github sponsorship of the people who spend a lot of time supporting AudioKit.

4. We want to inspire the next generation of audio app developers and we do that by highlighting AudioKit-powered apps and by creating our own apps under the "AudioKit Pro" brand including the world's most downloaded synth "AudioKit Synth One" and a host of other AudioKit Pro apps.

# Packages / Layer Diagram

<img src="/images/AudioKitLayers.svg" width=100%>

The Cookbook demo app layer is an example of where your app would be in this diagram. It could depend on any subset of the packages below it.

Packages can depend on other packages, and this is shown in the example of SporthAudioKit depending on (on top of) SoundpipeAudioKit.

The <i>AAA</i>AudioKit...<i>ZZZ</i>AudioKit blocks in the layer diagram above are placeholders for the many different packages that extend AudioKit.


| Package Name                                        | Description                                   |
|-----------------------------------------------------|-----------------------------------------------|
| [AudioKitUI](/Packages/AudioKitUI)                  | Waveform visualization and UI components      |
| [Devoloop AudioKit](/Packages/DevoloopAudioKit)     | Guitar processors                             |
| [Dunne AudioKit](/Packages/DunneAudioKit)           | Chorus, Flanger, Sampler, Stereo Delay, Synth |
| [Microtonal AudioKit](/Packages/MicrotonalAudioKit) | Custom tuning tables                          |
| [Soul AudioKit](/Packages/SoulAudioKit)             | Diode Clipper and basis for more development  |
| [Soundpipe AudioKit](/Packages/SoulAudioKit)        | Oscillators, Effects, Filters, and more       |
| [Sporth AudioKit](/Packages/SporthAudioKit)         | Operations for complex DSP with simple syntax |
| [STK AudioKit](/Packages/STKAudioKit)               | Stanford Synthesis Toolkit physical models    |


# AudioKit.io (this website)

This web site is created from the main AudioKit repository on Github. In that repository there is a `docs` folder that contains all of the documnets that appear here. Updating the AudioKit.io is the same as updating AudioKit, simply create a pull request with your proposed changes.  Base your changes off of the `develop` branch and once merged, they will appear on the website. 

# Examples

The primary source for AudioKit examples is the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook). This app contains all of the mini-examples that used to be included with AudioKit.

Larger examples have been moved to their own repositories:

* [Analog Synth X](https://github.com/AudioKit/AnalogSynthX)
* [AudioKit Synth One](https://github.com/AudioKit/AudioKitSynthOne)
* [Audio Unit Manager](https://github.com/AudioKit/AudioUnitManager)
* [File Converter](https://github.com/AudioKit/FileConverter) - Updated for AudioKit 5
* [Flanger and Chorus](https://github.com/AudioKit/FlangerAndChorus) - Updated for AudioKit 5
* [MIDI File Edit And Sync](https://github.com/AudioKit/MIDIFileEditAndSync)
* [MIDI Sequencer](https://github.com/AudioKit/MIDISequencer)
* [MIDI Track View](https://github.com/AudioKit/MIDITrackView)
* [Nodality](https://github.com/AudioKit/Nodality)
* [Output Splitter](https://github.com/AudioKit/OutputSplitter)
* [Particles](http://github.com/AudioKit/Particles/)
* [Player Demo](https://github.com/AudioKit/PlayerDemo)
* [ROM Player](https://github.com/AudioKit/ROMPlayer)
* [SamplerDemo](http://github.com/AudioKit/SamplerDemo/)
* [Simple Audio Unit](https://github.com/AudioKit/SimpleAudioUnit)
* [Song Processor](http://github.com/AudioKit/SongProcessor)

