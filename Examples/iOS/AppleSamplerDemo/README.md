# AudioKit Sampler Demo

The sampler uses recordings of sounds that were preloaded into Sounds directory of the project folder.

Again, like we did in Sequencer Demo we create an instance of an Conductor():

```
    let conductor = Conductor()
```

And then we jump right into Conductor.swift file where we can find the same declarations for a basic sequencer, a mixing node, a filter node, a playback node to generate audio, and a mixing node.

```
    var sequence: AKAppleSequencer?
    var mixer = AKMixer()
    var filter: AKMoogLadder?
    var arpeggioSynthesizer = AKAppleSampler()
    var arpeggioVolume: AKBooster?
```

During the init() function we initialize the instruments, connect them to a mixing node, create a filter node from a mixing one, and then start the AudioKit engine.


```
    arpeggioVolume = AKBooster(arpeggioSynthesizer)
    mixer.connect(arpeggioVolume!)
    filter = AKMoogLadder(mixer)
    AudioKit.output = filter
    arpeggioSynthesizer.loadEXS24("Sounds/Sampler Instruments/sqrTone1")
    AudioKit.start()
    sequence = AKAppleSequencer(filename: "seqDemo", engine: AudioKit.engine)
    sequence!.avTracks[1].destinationAudioUnit = arpeggioSynthesizer.samplerUnit
```