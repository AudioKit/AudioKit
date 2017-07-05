//: ## Sequencer
//:
import AudioKitPlaygrounds
import AudioKit

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var piano = AKMIDISampler()
piano.enableMIDI(AKMIDI().client, name: "Piano")
try piano.loadWav("Samples/FM Piano")

var bell = AKMIDISampler()
bell.enableMIDI(AKMIDI().client, name: "Bell")
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

    var buttons = [AKButton(title: "") {}, AKButton(title: "") {}, AKButton(title: "") {}, AKButton(title: "") {}]
    
    override func setup() {

        addTitle("Sequencer")
        addLabel("Set the global output for the sequencer:")
        addSubview(AKButton(title: "Use FM Piano As Global Output") {
            sequencer.stop()
            sequencer.setGlobalMIDIOutput(piano.midiIn)
//            self.updateButtons()
            sequencer.play()
        })
        addSubview(AKButton(title: "Use Bell As Global Output", color: AKColor.red) {
            sequencer.stop()
            sequencer.setGlobalMIDIOutput(bell.midiIn)
//            self.updateButtons()
            sequencer.play()
        })
        addLabel("Or set the tracks individually:")
        
        for i in 1 ... buttons.count  {
            buttons[i-1] = AKButton(title: "Track \(i): FM Piano") {
                self.toggle(track: i)
            }
            addSubview(buttons[i-1])
        }
    }

    func toggle(track i: Int) {
        sequencer.stop()
        if buttons[i-1].title != "Track \(i): Bell" {
            sequencer.tracks[i].setMIDIOutput(bell.midiIn)
            buttons[i-1].title = "Track \(i): Bell"
            buttons[i-1].color = .red
        } else {
            sequencer.tracks[i].setMIDIOutput(piano.midiIn)
            buttons[i-1].title == "Track \(i): FM Piano"
            buttons[i-1].color = .green
            
        }
        sequencer.play()

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
