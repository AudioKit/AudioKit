//: ## Drum Sequencer


import AudioKit

let drums = MIDISampler()

engine.output = drums
try engine.start()

let bassDrumFile = try AVAudioFile(readFileName: "Samples/Drums/bass_drum_C1.wav")
let clapFile = try AVAudioFile(readFileName: "Samples/Drums/clap_D#1.wav")
let closedHiHatFile = try AVAudioFile(readFileName: "Samples/Drums/closed_hi_hat_F#1.wav")
let hiTomFile = try AVAudioFile(readFileName: "Samples/Drums/hi_tom_D2.wav")
let loTomFile = try AVAudioFile(readFileName: "Samples/Drums/lo_tom_F1.wav")
let midTomFile = try AVAudioFile(readFileName: "Samples/Drums/mid_tom_B1.wav")
let openHiHatFile = try AVAudioFile(readFileName: "Samples/Drums/open_hi_hat_A#1.wav")
let snareDrumFile = try AVAudioFile(readFileName: "Samples/Drums/snare_D1.wav")

try drums.loadAudioFiles([bassDrumFile,
                          clapFile,
                          closedHiHatFile,
                          hiTomFile,
                          loTomFile,
                          midTomFile,
                          openHiHatFile,
                          snareDrumFile])

let sequencer = AppleSequencer(filename: "4tracks")
sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
sequencer.debug()
sequencer.setGlobalMIDIOutput(drums.midiIn)
sequencer.enableLooping(Duration(beats: 4))
sequencer.setTempo(150)


class LiveView: View {

    override func viewDidLoad() {
        addTitle("Drum Sequencer")

        addView(Button(title: "Play") { button in
            if sequencer.isPlaying {
                sequencer.stop()
                sequencer.rewind()
                button.title = "Play"
            } else {
                sequencer.play()
                button.title = "Stop"
            }
        })

        sequencer.tracks[0].add(noteNumber: 24, velocity: 127, position: Duration(beats: 0), duration: Duration(beats: 1))

        sequencer.tracks[0].add(noteNumber: 24, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 1))

        sequencer.tracks[1].add(noteNumber: 26, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 1))

        for i in 0 ... 7 {
            sequencer.tracks[2].add(
                noteNumber: 30,
                velocity: 80,
                position: Duration(beats: i / 2.0),
                duration: Duration(beats: 0.5))
        }

        sequencer.tracks[3].add(noteNumber: 26, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 1))

        addView(Button(title: "Randomize Hi-hats") { _ in

            sequencer.tracks[2].clearRange(start: Duration(beats: 0), duration: Duration(beats: 4))
            for i in 0 ... 15 {
                sequencer.tracks[2].add(
                    noteNumber: MIDINoteNumber(30 + Int(AUValue.random(in: 0 ... 1.99))),
                    velocity: MIDIVelocity(AUValue.random(in: 80 ... 127)),
                    position: Duration(beats: i / 4.0),
                    duration: Duration(beats: 0.5))
            }

        })

        addView(Slider(property: "Tempo", value: 150, range: 60 ... 300, format: "%0.0f") {
            sliderValue in
            sequencer.setTempo(sliderValue)
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
