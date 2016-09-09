//: ## Recording Nodes
//: AKNodeRecorder allows you to record the output of a specific node.
//: Let's record a sawtooth solo.

import XCPlayground
import AudioKit

//: Set up a source to be recorded
var oscillator = AKOscillator(waveform: AKTable(.Sawtooth))
var currentAmplitude = 0.1
var currentRampTime = 0.2

//: Pass our Oscillator thru a mixer. It fixes a problem with raw oscillator
//: nodes that can only be recorded once they passed thru an AKMixer.

let oscMixer = AKMixer(oscillator)

//: Let's add some space to our oscillator
let reverb = AKReverb(oscMixer)
reverb.loadFactoryPreset(.LargeHall)
reverb.dryWetMix = 0.5

//: Create an AKAudioFile to record to:
let tape = try? AKAudioFile()
//: We set a player to playback our "tape"
let player = try? AKAudioPlayer(file: tape!)

//: Mix our reverberated oscillator with our player, so we can listen to both.
let mixer = AKMixer(player!, reverb)
AudioKit.output = mixer

AudioKit.start()

//: Now we set an AKNodeRecorder to our oscillator. You can change the recorded
//: node to "reverb" if you prefer to record a "wet" oscillator...
let recorder = try? AKNodeRecorder(node: oscMixer, file: tape!)


//: Build our User interface

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var recordLabel: Label?
    var playLabel: Label?

    override func setup() {
        addTitle("Recording Nodes")

        recordLabel = addLabel("Press Record to Record...")

        addSubview(AKButton(title: "Record", color: AKColor.redColor()) {
            if recorder!.isRecording {
                let dur = String(format: "%0.3f seconds", recorder!.recordedDuration)
                self.recordLabel!.text = "Stopped. (\(dur) recorded)"
                recorder?.stop()
                return "Record"
            } else {
                self.recordLabel!.text = "Recording..."
                try? recorder?.record()
                return "Stop"
            }})


        addSubview(AKButton(title: "Reset Recording", color: AKColor.redColor()) {
            self.recordLabel!.text = "Tape Cleared!"
            try? recorder?.reset()
            return "Reset Recording"
            })

        playLabel = addLabel("Press Play to playback...")

        addSubview(AKButton(title: "Play") {
            if player!.isPlaying {
                self.playLabel!.text = "Stopped playback!"
                player?.stop()
                return "Play"
            } else {
                try? player?.reloadFile()
                // If the tape is not empty, we can play it !...
                if player?.audioFile.duration > 0 {
                    self.playLabel!.text = "Playing..."
                    player?.completionHandler = self.callback
                    player?.play()
                } else {
                    self.playLabel!.text = "Tape is empty!..."
                }
                return "Stop"
            }})

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        self.addSubview(keyboard)
    }

    func callback() {
        // We use Dispatch_async to refresh UI as callback is invoked from a background thread
        dispatch_async(dispatch_get_main_queue()) {
            self.playLabel!.text = "Finished playing!"
        }
    }

    // Synth UI
    func noteOn(note: MIDINoteNumber) {
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampTime = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampTime for volume
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }

    func noteOff(note: MIDINoteNumber) {
        oscillator.amplitude = 0
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
