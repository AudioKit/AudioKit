//: ## Recording Nodes
//: NodeRecorder allows you to record the output of a specific node.
//: Let's record a sawtooth solo.

import AudioKit

//: Set up a source to be recorded
var oscillator = Oscillator(waveform: Table(.sawtooth))
var currentAmplitude = 0.1
var currentRampDuration = 0.2

//: Pass our Oscillator thru a mixer. It fixes a problem with raw oscillator
//: nodes that can only be recorded once they passed thru an Mixer.

let oscMixer = Mixer(oscillator)

//: Let's add some space to our oscillator
let reverb = Reverb(oscMixer)
reverb.loadFactoryPreset(.largeHall)
reverb.dryWetMix = 0.5

//: Create an AVAudioFile to record to:
let tape = try AVAudioFile()
//: We set a player to playback our "tape"
let player = try AudioPlayer(file: tape)

//: Mix our reverberated oscillator with our player, so we can listen to both.
let mixer = Mixer(player, reverb)

//: Now we set an NodeRecorder to our oscillator. You can change the recorded
//: node to "reverb" if you prefer to record a "wet" oscillator...
let recorder = try NodeRecorder(node: mixer, file: tape)

engine.output = mixer

try engine.start()

//: Build our User interface

class LiveView: View, KeyboardDelegate {


    override func viewDidLoad() {
        addTitle("Recording Nodes")

        recordLabel = addLabel("Press Record to Record...")

        addView(Button(title: "Record", color: CrossPlatformColor.red) { button in
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
                    Log("Couldn't record")
                }
                button.title = "Stop"
            }
        })

        addView(Button(title: "Save") { button in
            recorder.audioFile?.exportAsynchronously(name: "test",
                                      baseDir: .documents,
                                      exportFormat: .caf) { [weak self] _, _ in
            }
            button.title = "Saved"
        })

        addView(Button(title: "Reset Recording") { button in
            self.recordLabel.stringValue = "Tape Cleared!"
            do {
                try recorder.reset()
            } catch {
                Log("Couldn't reset.")
            }
            button.title = "Reset Recording"
        })

        playLabel = addLabel("Press Play to playback...")

        playButton = Button(title: "Play") { button in
            if player.isPlaying {
                self.playLabel.stringValue = "Stopped playback!"
                player.stop()
                button.title = "Play"
            } else {
                do {
                    try player.reloadFile()
                } catch {
                    Log("Couldn't reload file.")
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

        let keyboard = KeyboardView(width: 440, height: 100)
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
