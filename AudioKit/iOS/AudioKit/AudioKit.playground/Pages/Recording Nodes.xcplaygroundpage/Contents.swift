//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Recording Nodes
//: ### AKNodeRecorder allows you to record the output of a specific node
//: ##
//: ### Let's record a sawtooth solo.

import XCPlayground
import AudioKit

//: Here we set up a source to be recorded
var oscillator = AKOscillator(waveform: AKTable(.Sawtooth))
var currentAmplitude = 0.1
var currentRampTime = 0.2

//: We pass our Oscillator thru a mixer. It fixes a problem with raw oscillator nodes that can only be recorded once they passed thru an AKMixer.

let oscMixer = AKMixer(oscillator)

//: Let's add some space to our oscillator
let reverb = AKReverb(oscMixer)
reverb.loadFactoryPreset(.LargeHall)
reverb.dryWetMix = 0.5

//: We create an AKAudioFile to record to:
let tape = try? AKAudioFile()
//: We set a player to playback our "tape"
let player = try? AKAudioPlayer(file: tape!)

//: We mix our reverberated oscillator with our player, so we can listen to both.
let mixer = AKMixer(player!,reverb)
AudioKit.output = mixer

AudioKit.start()

//: Now we set an AKNodeRecorder to our oscillator. You can change the recorded node to "reverb" if you prefer to record a "wet" oscillator...
let recorder = try? AKNodeRecorder(node: oscMixer, file: tape!)


//: Here, we build our User interface

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var rampTimeLabel: Label?
    var recordLabel: Label?
    var replayLabel: Label?
    var speedLabel: Label?
    var autoInputLabel: Label?
    override func setup() {
        addTitle("AKNodeRecorder")

        addLineBreak()
        addLabel(" ")

        addLineBreak()
        let keyboard = KeyboardView(width: playgroundWidth, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)

        addLineBreak()
        addLabel(" ")
        addLineBreak()
        addLabel(" ")
        addLineBreak()
        addLabel(" ")
        addLineBreak()
        addLabel(" ")
        recordLabel = addLabel("Press Record to Record...")

        addButton("Record", action: #selector(record))
        addButton("StopRecord", action: #selector(stopRecord))
        addButton("reset", action: #selector(reset))
        addLineBreak()

        addLineBreak()
        replayLabel = addLabel("Press Replay to play-back...")

        addButton("Replay", action: #selector(replay))
        addButton("StopReplay", action: #selector(stopReplay))

    }

    func record() {
        recordLabel!.text = "Recording..."
        try? recorder?.record()
    }

    func stopRecord() {
        recordLabel!.text = "Stopped. ( \(recorder!.recordedDuration) seconds recorded)"
        recorder?.stop()
    }

    func reset() {
        recordLabel!.text = "Tape Cleared !"
        try? recorder?.reset()
    }

    func callback() {
        // We use Dispatch_async to refresh UI as callback is invoked from a background thread
         dispatch_async(dispatch_get_main_queue()) {
        self.replayLabel!.text = "Finished to replay!"}
    }

    func replay() {
        // We reloadFile() to refresh before playing
        try? player?.reloadFile()
        // If the tape is not empty, we can play it !...
        if player?.audioFile.duration > 0 {
            replayLabel!.text = "Replaying..."
            player?.completionHandler = callback
            player?.play()
        } else {
            replayLabel!.text = "Tape is empty!..."
        }
    }

    func stopReplay() {
        replayLabel!.text = "Replay stopped !"
        player?.stop()
    }



    // Synth UI
    func noteOn(note: Int) {
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

    func noteOff(note: Int) {
        oscillator.amplitude = 0
    }
}



let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
