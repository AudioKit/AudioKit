//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Recording from Microphone
//:
import XCPlayground
import AudioKit

let mic = AKMicrophone()

let file = try AKAudioFile(forReadingWithFileName: "recording",  fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)

var reverb =  AKReverb(mic)
reverb.loadFactoryPreset(.Plate)
AudioKit.output = AKMixer(reverb, player)

AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    var recorder = AKMicrophoneRecorder(file!)

    override func setup() {
        addTitle("Recording from Microphone")

        addButton("Record", action: #selector(record))
        addButton("Stop", action: #selector(stop))

        addLabel("Playback")

        addButton("Play", action: #selector(play))
    }

    func play() {
        player.stop()
        player.replaceFile(file!)
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

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@nex
