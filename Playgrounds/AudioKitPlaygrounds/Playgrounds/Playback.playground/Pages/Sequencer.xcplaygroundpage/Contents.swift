//: ## Sequencer
//:

import AudioKit

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var piano = MIDISampler()
try piano.loadWav("Samples/FM Piano")

var bell = MIDISampler()
try bell.loadWav("Samples/Bell")

var mixer = Mixer(piano, bell)

let reverb = CostelloReverb(mixer)

let dryWetMixer = DryWetMixer(mixer, reverb, balance: 0.2)
engine.output = dryWetMixer

//: Create the sequencer after AudioKit's output has been set
//: Load in a midi file, and set the sequencer to the main audiokit engine
var sequencer = AppleSequencer(filename: "4tracks")

//: Do some basic setup to make the sequence loop correctly
sequencer.setLength(Duration(beats: 4))
sequencer.enableLooping()
sequencer.setGlobalMIDIOutput(piano.midiIn)

try engine.start()
sequencer.play()

//: Set up a basic UI for setting outputs of tracks

class LiveView: View {

    enum State {
        case bell, piano
    }
    var buttons: [Button] = []
    var states: [State] = [.piano, .piano, .piano, .piano]

    override func viewDidLoad() {

        addTitle("Sequencer")

        for i in 0 ..< 4 {
            let button = Button(title: "Track \(i + 1): FM Piano") { _ in
                self.states[i] = self.states[i] == .bell ? .piano : .bell
                self.update()
            }
            addView(button)
            button.color = .green
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
PlaygroundPage.current.liveView = LiveView()
