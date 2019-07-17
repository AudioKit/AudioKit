# AudioKit Sequencer Demo

First we create an instance of an Conductor() to follow the principles of MVC (Model-View-Controller):

```
    let conductor = Conductor()
```

And then the file Conductor.swift comes where amazing happens. We create the object of AKMIDI() that handles both the MIDI input and output, an instance of AKFMOscillatorBank() to generate audio, and the last property stands for the pointer to Apple’s Reverb2 Audio Unit.

```
    let midi = AKMIDI()
    var fmOscillator = AKFMOscillatorBank()
    var melodicSound: AKMIDINode?
    var verb: AKReverb2?
```

Then we create some instruments, where AKMIDIInstrument() is a version of AKInstrument() specifically targeted to instruments that should be triggerable via MIDI or sequenced with the sequencer.

```
    var bassDrumInstrument: BDInstrument?
    var bassDrum: AKMIDIInstrument?
```

Finally, we create a basic sequencer, a node that mixes its inputs to a single output, and a dynamic node.

```
    var sequence = AKAppleSequencer()
    var mixer = AKMixer()
    var pumper: AKCompressor?
```

During the init() function we initialize the instruments, mix them to a single output, and then start the AudioKit engine.

```
    bassDrumInstrument = BDInstrument(voiceCount: 1)
    bassDrumInstrument?.amplitude = 1
    bassDrum = AKMIDIInstrument(instrument: bassDrumInstrument!)
    bassDrum?.enableMIDI(midi.client, name: "bassDrum midi in")

    pumper = AKCompressor(mixer)

    AudioKit.output = pumper
    AudioKit.start()
```

And then we're able to generate a new track for our sequence for every instrument we've got so far (bass drum, snare drum, snare ghost):

```
    sequence.newTrack()
    sequence.tracks[Sequence.BassDrum.rawValue].setMIDIOutput((bassDrum?.midiIn)!)
    generateBassDrumSequence()
```