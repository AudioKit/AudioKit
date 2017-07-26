//: ## Sequencer
//:
import AudioKitPlaygrounds
import AudioKit

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var piano = AKMIDISampler()
try piano.loadWav("Samples/FM Piano")

var bell = AKMIDISampler()
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
sequencer.setGlobalMIDIOutput(piano.midiIn)

AudioKit.start()
sequencer.play()

//: Set up a basic UI for setting outputs of tracks

class PlaygroundView: AKPlaygroundView {

    enum State {
        case bell, piano
    }
    var buttons: [AKButton] = []
    var states: [State] = [.piano, .piano, .piano, .piano]

    override func setup() {

        addTitle("Sequencer")

        for i in 0 ..< 4 {
            let button = AKButton(title: "Track \(i + 1): FM Piano") {
                self.states[i] = self.states[i] == .bell ? .piano : .bell
                self.update()
            }
            addSubview(button)
            buttons.append(button)
        }
    }

    func update() {
        sequencer.stop()
        for i in 0 ..< 4 {
            if states[i] == .bell {
                sequencer.tracks[i + 1].setMIDIOutput(bell.midiIn)
                buttons[i].title = "Track \(i + 1): Bell"
                buttons[i].color = .red
            } else {
                sequencer.tracks[i + 1].setMIDIOutput(piano.midiIn)
                buttons[i].title = "Track \(i + 1): FM Piano"
                buttons[i].color = .green

            }
        }
        sequencer.play()

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
