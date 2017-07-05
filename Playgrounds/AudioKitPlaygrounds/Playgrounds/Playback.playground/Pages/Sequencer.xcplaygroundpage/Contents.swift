//: ## Sequencer
//:
import AudioKitPlaygrounds
import AudioKit

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var piano = AKSampler()
try piano.loadWav("Samples/FM Piano")

var bell = AKSampler()
try bell.loadWav("Samples/Bell")

var mixer = AKMixer(piano, bell)

let reverb = AKCostelloReverb(mixer)

let dryWetMixer = AKDryWetMixer(mixer, reverb, balance: 0.2)
AudioKit.output = dryWetMixer

//: Create the sequencer after AudioKit's output has been set
//: Load in a midi file, and set the sequencer to the main audiokit engine
var sequencer = AKSequencer(filename: "4tracks")

//: Do some basic setup to make the sequence loop correctly
sequencer.setLength(AKDuration(beats: 4))
sequencer.enableLooping()

AudioKit.start()
sequencer.play()

//: Set up a basic UI for setting outputs of tracks

class PlaygroundView: AKPlaygroundView {
    var button1: AKButton!
    var button2: AKButton!
    var button3: AKButton!
    var button4: AKButton!

    override func setup() {

        addTitle("Sequencer")
        addLabel("Set the global output for the sequencer:")
        addSubview(AKButton(title: "Use FM Piano As Global Output") {
            sequencer.stop()
            sequencer.setGlobalAVAudioUnitOutput(piano.samplerUnit)
            self.updateButtons()
            sequencer.play()
        })
        addSubview(AKButton(title: "Use Bell As Global Output", color: AKColor.red) {
            sequencer.stop()
            sequencer.setGlobalAVAudioUnitOutput(bell.samplerUnit)
            self.updateButtons()
            sequencer.play()
        })
        addLabel("Or set the tracks individually:")
        button1 = AKButton(title: "Track 1: FM Piano") {
            self.toggle(track: 1)
        }
        button2 = AKButton(title: "Track 2: FM Piano") {
            self.toggle(track: 2)
        }
        button3 = AKButton(title: "Track 3: FM Piano") {
            self.toggle(track: 3)
        }
        button4 = AKButton(title: "Track 4: FM Piano") {
            self.toggle(track: 4)
        }
        addSubview(button1)
        addSubview(button2)
        addSubview(button3)
        addSubview(button4)
    }

    func toggle(track: Int) {
        sequencer.stop()
        if sequencer.tracks[track].destinationAudioUnit == bell.samplerUnit {
            sequencer.tracks[track].destinationAudioUnit = piano.samplerUnit
        } else {
            sequencer.tracks[track].destinationAudioUnit = bell.samplerUnit
        }
        updateButtons()
    }

    func updateButtons() {
        let buttons: [AKButton] = [button1, button2, button3, button4]
        for i in 0 ..< buttons.count {
            if sequencer.tracks[i + 1].destinationAudioUnit == bell.samplerUnit {
                buttons[i].title = "Track \(i + 1): Bell"
                buttons[i].color = AKColor.red

            } else {
                buttons[i].title = "Track \(i + 1): FM Piano"
                buttons[i].color = AKColor.green
            }
        }
        sequencer.play()
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
