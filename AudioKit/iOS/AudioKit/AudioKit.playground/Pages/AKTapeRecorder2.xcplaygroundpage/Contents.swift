//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKTapeRecorder
//: ### combines an AKNodeRecorder and an AKAudioPlayer to build a tapeRecoder with auto-input.

import XCPlayground
import AudioKit



public class AKTapeRecorder
{
    private var node: AKNode
    private var recorder: AKNodeRecorder
    private var player: AKAudioPlayer
    private var tape: AKAudioFile

    // mix input and playback to feed the output
    private var mixer: AKDryWetMixer
    // If true, input sound is passed thru
    // while playback is not playing...
    public var autoInput = true {

        willSet {
            if newValue == true {
                idleBalance = 0
            } else {
                idleBalance = 1
            }
            self.mixer.balance = idleBalance
        }
    }
    private var idleBalance: Double = 0

    // CallBack triggered when playback ends to play
    // can be set during init or later...
    public var playbackCompletionHandler: AKCallback?


    public init(node: AKNode, file:AKAudioFile? = nil, playbackCompletionHandler: AKCallback? = nil) throws
    {
        self.node = node

        do {
            self.recorder = try AKNodeRecorder(node: node, file: file)
        } catch let error as NSError {
            print ("ERROR AKTapeRecorder: couldn't initialize AKNodeRecorder ")
            throw error
        }

        self.tape = recorder.audioFile!

        do {
            player = try AKAudioPlayer(file: recorder.audioFile!)
        } catch let error as NSError {
            print ("ERROR AKTapeRecorder: couldn't initialize AKAudioPlayer ")
            throw error
        }

        self.playbackCompletionHandler = playbackCompletionHandler
        mixer = AKDryWetMixer(node, player, balance: idleBalance)

    }


    // used to balance the dry/wet mix (auto-input)
    private func internalCallback() {
        self.mixer.balance = idleBalance
        playbackCompletionHandler?()
        print ("replay ended")
    }

    /// PlayBack what was recorded
    public func replay() {
        if player.isPlaying { return }

        try? player.reloadFile()

        mixer.balance = 1
        player.completionHandler  = internalCallback
        player.play()
    }

    /// Stop replay
    public func stopReplay() {
        if player.isPlaying {
            player.stop()
            mixer.balance = idleBalance
        } else {
            print ("ERROR AKTapeRecorder: Cannot stop, AKTapeRecorder is not replaying!")
        }

    }
    /// Record
    public func record() {

        recorder.record()
    }

    /// Stop recording
    public func stopRecord() {
        recorder.stop()
    }

    /// Clear the tape
    public func reset() {
        try? recorder.reset()
    }

    public var output: AKDryWetMixer {
        return mixer
    }

    public var isPlaying: Bool {
        return player.isPlaying
    }

    public var recordedDuration: Double {
        return recorder.recordedDuration    }
}


var oscillator = AKSawtoothOscillator()
var currentAmplitude = 0.1
var currentRampTime = 0.2

let reverb = AKReverb(oscillator)

reverb.loadFactoryPreset(.LargeHall)
reverb.dryWetMix = 0.5

let tapeRecorder = try? AKTapeRecorder(node: reverb)


AudioKit.output = tapeRecorder?.output

AudioKit.start()

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
        addTitle("AKTapeRecorder")

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


        autoInputLabel =  addLabel("Auto-Input")
        addButton("On", action: #selector(setAutoInputToTrue))
        addButton("Off", action: #selector(setAutoInputToFalse))

        addLineBreak()
        replayLabel = addLabel("Press Replay to play-back...")

        addButton("Replay", action: #selector(replay))
        addButton("StopReplay", action: #selector(stopReplay))

    }


    func record() {
        recordLabel!.text = "Recording..."
        tapeRecorder?.record()
    }

    func stopRecord() {
        recordLabel!.text = "Stopped. ( \(tapeRecorder!.recordedDuration) seconds recorded)"

        tapeRecorder?.stopRecord()
    }

    func reset() {
        recordLabel!.text = "Tape Cleared !"
        tapeRecorder?.reset()
    }
    //
    func setAutoInputToTrue() {
        autoInputLabel!.text = "Auto-Input is On"
        tapeRecorder?.autoInput = true
    }

    func setAutoInputToFalse() {
        autoInputLabel!.text = "Auto-Input is Off (source is muted)"
        tapeRecorder?.autoInput = false
    }

    func callback() {

        // Use Dispatch_async to refresh UI as callback is invoked from a background thread
         dispatch_async(dispatch_get_main_queue()) {
        self.replayLabel!.text = "Finished to replay!"}
        print ("callback trig")
    }

    func replay() {
        if tapeRecorder?.recordedDuration > 0 {
            replayLabel!.text = "Replaying..."
            tapeRecorder!.playbackCompletionHandler = callback

            tapeRecorder?.replay()
        } else {
            replayLabel!.text = "Tape is empty!..."
        }
    }

    func stopReplay() {
        replayLabel!.text = "Replay stopped !"
        tapeRecorder?.stopReplay()
    }


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


    func setAmplitude(slider: Slider) {
        currentAmplitude = Double(slider.value)
        let amp = String(format: "%0.3f", currentAmplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }

    func setRampTime(slider: Slider) {
        currentRampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", currentRampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
    }
}



let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
