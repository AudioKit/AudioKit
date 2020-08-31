//: ## Recording Nodes
//: AKNodeRecorder allows you to record the output of a specific node.
//: Let's record a sawtooth solo.
import AudioKitPlaygrounds
import AudioKit

//: Set up a source to be recorded
var oscillator = AKOscillator(waveform: AKTable(.sawtooth))
var currentAmplitude = 0.1
var currentRampDuration = 0.2

//: Pass our Oscillator thru a mixer. It fixes a problem with raw oscillator
//: nodes that can only be recorded once they passed thru an AKMixer.

let oscMixer = AKMixer(oscillator)

//: Let's add some space to our oscillator
let reverb = AKReverb(oscMixer)
reverb.loadFactoryPreset(.largeHall)
reverb.dryWetMix = 0.5

//: Create an AKAudioFile to record to:
let tape = try AKAudioFile()
//: We set a player to playback our "tape"
let player = try AKAudioPlayer(file: tape)

//: Mix our reverberated oscillator with our player, so we can listen to both.
let mixer = AKMixer(player, reverb)

//: Now we set an AKNodeRecorder to our oscillator. You can change the recorded
//: node to "reverb" if you prefer to record a "wet" oscillator...
let recorder = try AKNodeRecorder(node: mixer, file: tape)

engine.output = mixer

try engine.start()

//: Build our User interface
import AudioKitUI

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var recordLabel: AKLabel!
    var playLabel: AKLabel!
    var playButton: AKButton!

    override func viewDidLoad() {
        addTitle("Recording Nodes")

        recordLabel = addLabel("Press Record to Record...")

        addView(AKButton(title: "Record", color: AKColor.red) { button in
            if recorder.isRecording {
                let dur = String(format: "%0.3f seconds", recorder.recordedDuration)
                self.recordLabel.stringValue = "Stopped. (\(dur) recorded)"
                recorder.stop()
                button.title = "Record"
            } else {
                self.recordLabel.stringValue = "Recording..."
                do {
                    try recorder.record()
                } catch {
                    AKLog("Couldn't record")
                }
                button.title = "Stop"
            }
        })

        addView(AKButton(title: "Save") { button in
            recorder.audioFile?.exportAsynchronously(name: "test",
                                      baseDir: .documents,
                                      exportFormat: .caf) { [weak self] _, _ in
            }
            button.title = "Saved"
        })

        addView(AKButton(title: "Reset Recording") { button in
            self.recordLabel.stringValue = "Tape Cleared!"
            do {
                try recorder.reset()
            } catch {
                AKLog("Couldn't reset.")
            }
            button.title = "Reset Recording"
        })

        playLabel = addLabel("Press Play to playback...")

        playButton = AKButton(title: "Play") { button in
            if player.isPlaying {
                self.playLabel.stringValue = "Stopped playback!"
                player.stop()
                button.title = "Play"
            } else {
                do {
                    try player.reloadFile()
                } catch {
                    AKLog("Couldn't reload file.")
                }
                // If the tape is not empty, we can play it !...
                if player.audioFile.duration > 0 {
                    self.playLabel.stringValue = "Playing..."
                    player.completionHandler = self.callback
                    player.play()
                    button.title = "Stop"
                } else {
                    self.playLabel.stringValue = "Tape is empty!..."
                }
            }
        }
        addView(playButton)

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        self.addView(keyboard)
    }

    func callback() {
        // We use Dispatch_async to refresh UI as callback is invoked from a background thread
        DispatchQueue.main.async {
            self.playButton.title = "Play"
            self.playLabel.stringValue = "Finished playing!"
        }
    }

    // Synth UI
    func noteOn(note: MIDINoteNumber) {
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampDuration = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampDuration for volume
        oscillator.rampDuration = currentRampDuration
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }

    func noteOff(note: MIDINoteNumber) {
        oscillator.amplitude = 0
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
