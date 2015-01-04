//
//  Conductor.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

class Conductor {

    var toneGenerator = ToneGenerator()
    var fx: EffectsProcessor
    var currentNotes = [ToneGeneratorNote](count: 13, repeatedValue: ToneGeneratorNote())
    let frequencies = [440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880]

    init() {
        AKOrchestra.addInstrument(toneGenerator)
        fx = EffectsProcessor(audioSource: toneGenerator.auxilliaryOutput)
        AKOrchestra.addInstrument(fx)
        AKOrchestra.start()

        fx.play()
    }

    func play(key: Int) {
        let note = ToneGeneratorNote()
        let frequency = Float(frequencies[key])
        note.frequency.value = frequency
        toneGenerator.playNote(note)
        currentNotes[key]=note;
    }
    func stop(key: Int) {
        let noteToStop = currentNotes[key]
        noteToStop.stop()
    }

    func release(key: Int) {
        let noteToRelease = currentNotes[key]
        
        var releaseSequence = AKSequence()
        
        let decreaseVolumeEvent = AKEvent{noteToRelease.amplitude.value *= 0.95}

        for i in 1...100 {
            releaseSequence.addEvent(decreaseVolumeEvent, afterDuration: 0.02)
        }
        releaseSequence.addEvent(AKEvent{noteToRelease.stop()}, afterDuration: 0.01)
        
        releaseSequence.play()
    }

    func setReverbFeedbackLevel(feedbackLevel: Float) {
        fx.feedbackLevel.value = feedbackLevel
    }
    func setToneColor(toneColor: Float) {
        toneGenerator.toneColor.value = toneColor
    }
}
