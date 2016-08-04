//: ## Sequencer
//:
import XCPlayground
import AudioKit

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var fmPianoSampler = AKSampler()
fmPianoSampler.loadWav("FM Piano")

var bellSampler = AKSampler()
bellSampler.loadWav("Bell")

var mixer = AKMixer(fmPianoSampler, bellSampler)

let reverb = AKCostelloReverb(mixer)

let dryWetmixer = AKDryWetMixer(mixer, reverb, balance: 0.2)
AudioKit.output = dryWetmixer

//: Create the sequencer after AudioKit's output has been set
//: Load in a midi file, and set the sequencer to the main audiokit engine
var sequencer = AKSequencer(filename: "4tracks", engine: AudioKit.engine)


//: Do some basic setup to make the sequence loop correctly
sequencer.setLength(AKDuration(beats: 4))
sequencer.enableLooping()

AudioKit.start()
sequencer.play()

//: Set up a basic UI for setting outputs of tracks

class PlaygroundView: AKPlaygroundView {
    var button1: AKButton?
    var button2: AKButton?
    var button3: AKButton?
    var button4: AKButton?

    override func setup() {

        addTitle("Sequencer")
        addLabel("Set the global output for the sequencer:")
        addSubview(AKButton(title: "Use FM Piano As Global Output") {
            sequencer.stop()
            sequencer.setGlobalAVAudioUnitOutput(fmPianoSampler.samplerUnit)
            self.updateButtons()
            sequencer.play()
            })
        addSubview(AKButton(title: "Use Bell As Global Output", color: AKColor.redColor()) {
            sequencer.stop()
            sequencer.setGlobalAVAudioUnitOutput(bellSampler.samplerUnit)
            self.updateButtons()
            sequencer.play()
        })
        addLabel("Or set the tracks individually:")
        button1 = AKButton(title: "Track 1: FM Piano") { self.toggleTrack(1) }
        button2 = AKButton(title: "Track 2: FM Piano") { self.toggleTrack(2) }
        button3 = AKButton(title: "Track 3: FM Piano") { self.toggleTrack(3) }
        button4 = AKButton(title: "Track 4: FM Piano") { self.toggleTrack(4) }
        addSubview(button1!)
        addSubview(button2!)
        addSubview(button3!)
        addSubview(button4!)
    }

    func toggleTrack(trackNumber: Int) {
        sequencer.stop()
        if sequencer.avTracks[trackNumber].destinationAudioUnit == bellSampler.samplerUnit {
            sequencer.avTracks[trackNumber].destinationAudioUnit = fmPianoSampler.samplerUnit
        } else {
            sequencer.avTracks[trackNumber].destinationAudioUnit = bellSampler.samplerUnit
        }
        updateButtons()
    }

    func updateButtons() {
        let buttons = [button1!, button2!, button3!, button4!]
        for i in 0 ..< buttons.count {
            if sequencer.avTracks[i + 1].destinationAudioUnit == bellSampler.samplerUnit {
                buttons[i].title = "Track \(i + 1): Bell"
                buttons[i].color = AKColor.redColor()

            } else {
                buttons[i].title = "Track \(i + 1): FM Piano"
                buttons[i].color = AKColor.greenColor()
            }
        }
        sequencer.play()
    }
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()