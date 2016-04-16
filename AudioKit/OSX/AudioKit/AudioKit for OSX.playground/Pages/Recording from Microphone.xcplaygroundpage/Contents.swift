//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Recording from Microphone
//:
import XCPlayground
import AudioKit

let mic = AKMicrophone()

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("recording", ofType: "wav")
var player = AKAudioPlayer(file!)

AudioKit.output = AKMixer(mic, player)

AudioKit.start()

let recorder = AKAudioRecorder(file!)

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?

    override func setup() {
        addTitle("Recording Mic")

        addButton("Record", action: #selector(record))
        addButton("Stop", action: #selector(stop))

        addLabel("Playback")

        addButton("Play", action: #selector(play))
    }

    func play() {
        player.stop()
        player.reloadFile()
        player.play()
    }

    func record() {
        recorder.record()
    }
    func stop() {
        recorder.stop()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
