// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

enum Synthesizer {
    case arpeggio, pad, bass
}

enum Instrument {
    case arpeggio, pad, bass, drum
}

enum Sound: String {
    case square, saw, pad, noisy
}

class Conductor {
    private var sequencer: AKAppleSequencer!
    private var mixer = AKMixer()
    private var arpeggioSynthesizer = AKMIDISampler(name: "Arpeggio Synth")
    private var padSynthesizer = AKMIDISampler(name: "Pad Synth")
    private var bassSynthesizer = AKMIDISampler(name: "Bass Synth")
    private var drumKit = AKMIDISampler(name: "Drums")
    private var filter: AKMoogLadder?

    init() {
        mixer = AKMixer(arpeggioSynthesizer, padSynthesizer, bassSynthesizer, drumKit)

        filter = AKMoogLadder(mixer)
        filter?.cutoffFrequency = 20_000
        engine.output = filter

        do {
            useSound(.square, synthesizer: .arpeggio)
            useSound(.saw, synthesizer: .pad)
            useSound(.saw, synthesizer: .bass)
            try drumKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        } catch {
            AKLog("A file was not found.")
        }
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        sequencer = AKAppleSequencer(filename: "seqDemo")
        sequencer.enableLooping()
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        sequencer.tracks[2].setMIDIOutput(bassSynthesizer.midiIn)
        sequencer.tracks[3].setMIDIOutput(padSynthesizer.midiIn)
        sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)

        sequencer.play()
    }

    func adjustVolume(_ volume: AUValue, instrument: Instrument) {
        let vol = volume * 2.0 // useful for gain
        switch instrument {
        case .arpeggio:
            arpeggioSynthesizer.volume = vol
        case .pad:
            padSynthesizer.volume = vol
        case .bass:
            bassSynthesizer.volume = vol
        case .drum:
            drumKit.volume = vol
        }
    }

    func adjustFilterFrequency(_ frequency: Float) {
        filter?.cutoffFrequency = frequency.denormalized(to: 30 ... 20_000, taper: 3)
    }

    func playSequence() {
        sequencer.play()
    }

    func stopSequence() {
        sequencer.stop()
    }

    func rewindSequence() {
        sequencer.rewind()
    }

    func setLength(_ length: Double) {
        AKLog("Setting Length \(length)")
        sequencer.setLength(AKDuration(beats: 16))
        for track in sequencer.tracks {
            track.resetToInit()
        }
        sequencer.setLength(AKDuration(beats: length))
        sequencer.setLoopInfo(AKDuration(beats: length), numberOfLoops: 0)
        sequencer.rewind()
    }

    func useSound(_ sound: Sound, synthesizer: Synthesizer) {
        var path = "Sounds/Sampler Instruments/"
        switch sound {
        case .square:
            path += "sqrTone1"
        case .saw:
            path += "sawPiano1"
        case .pad:
            path += "sawPad1"
        case .noisy:
            path += "noisyRez"
        }

        do {
            switch synthesizer {
            case .arpeggio:
                try arpeggioSynthesizer.loadEXS24(path)
            case .pad:
                try padSynthesizer.loadEXS24(path)
            case .bass:
                try bassSynthesizer.loadEXS24(path)
            }
        } catch {
            AKLog("Could not load EXS24")
        }
    }

    func adjustTempo(_ tempo: Float) {
        sequencer?.setRate(Double(tempo))
    }
}
