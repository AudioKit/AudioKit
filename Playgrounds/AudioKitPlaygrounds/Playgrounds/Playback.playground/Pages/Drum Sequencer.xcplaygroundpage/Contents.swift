//: ## Drum Sequencer

import AudioKitPlaygrounds
import AudioKit

let drums = AKMIDISampler()

engine.output = drums
try engine.start()

let bassDrumFile = try AKAudioFile(readFileName: "Samples/Drums/bass_drum_C1.wav")
let clapFile = try AKAudioFile(readFileName: "Samples/Drums/clap_D#1.wav")
let closedHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/closed_hi_hat_F#1.wav")
let hiTomFile = try AKAudioFile(readFileName: "Samples/Drums/hi_tom_D2.wav")
let loTomFile = try AKAudioFile(readFileName: "Samples/Drums/lo_tom_F1.wav")
let midTomFile = try AKAudioFile(readFileName: "Samples/Drums/mid_tom_B1.wav")
let openHiHatFile = try AKAudioFile(readFileName: "Samples/Drums/open_hi_hat_A#1.wav")
let snareDrumFile = try AKAudioFile(readFileName: "Samples/Drums/snare_D1.wav")

try drums.loadAudioFiles([bassDrumFile,
                          clapFile,
                          closedHiHatFile,
                          hiTomFile,
                          loTomFile,
                          midTomFile,
                          openHiHatFile,
                          snareDrumFile])

let sequencer = AKAppleSequencer(filename: "4tracks")
sequencer.clearRange(start: AKDuration(beats: 0), duration: AKDuration(beats: 100))
sequencer.debug()
sequencer.setGlobalMIDIOutput(drums.midiIn)
sequencer.enableLooping(AKDuration(beats: 4))
sequencer.setTempo(150)

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Drum Sequencer")

        addView(AKButton(title: "Play") { button in
            if sequencer.isPlaying {
                sequencer.stop()
                sequencer.rewind()
                button.title = "Play"
            } else {
                sequencer.play()
                button.title = "Stop"
            }
        })

        sequencer.tracks[0].add(noteNumber: 24, velocity: 127, position: AKDuration(beats: 0), duration: AKDuration(beats: 1))

        sequencer.tracks[0].add(noteNumber: 24, velocity: 127, position: AKDuration(beats: 2), duration: AKDuration(beats: 1))

        sequencer.tracks[1].add(noteNumber: 26, velocity: 127, position: AKDuration(beats: 2), duration: AKDuration(beats: 1))

        for i in 0 ... 7 {
            sequencer.tracks[2].add(
                noteNumber: 30,
                velocity: 80,
                position: AKDuration(beats: i / 2.0),
                duration: AKDuration(beats: 0.5))
        }

        sequencer.tracks[3].add(noteNumber: 26, velocity: 127, position: AKDuration(beats: 2), duration: AKDuration(beats: 1))

        addView(AKButton(title: "Randomize Hi-hats") { _ in

            sequencer.tracks[2].clearRange(start: AKDuration(beats: 0), duration: AKDuration(beats: 4))
            for i in 0 ... 15 {
                sequencer.tracks[2].add(
                    noteNumber: MIDINoteNumber(30 + Int(random(in: 0 ... 1.99))),
                    velocity: MIDIVelocity(random(in: 80 ... 127)),
                    position: AKDuration(beats: i / 4.0),
                    duration: AKDuration(beats: 0.5))
            }

        })

        addView(AKSlider(property: "Tempo", value: 150, range: 60 ... 300, format: "%0.0f") {
            sliderValue in
            sequencer.setTempo(sliderValue)
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
