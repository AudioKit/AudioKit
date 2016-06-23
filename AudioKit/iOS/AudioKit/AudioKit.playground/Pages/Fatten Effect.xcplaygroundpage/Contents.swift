//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Fatten Effect
//: ### This is a cool fattening effect that Matthew Flecher wanted for the Analog Synth X project, so it was developed here in a playground first.
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "mixloop.wav",  fromBaseDirectory: .resources)


//: Here we set up a player to the loop the file's playback
let player = try AKAudioPlayer(file: file)
player.looping = true

//: Define parameters that will be required
let input = AKStereoOperation.input
let fattenTimeParameter = AKOperation.parameters(0)
let fattenMixParameter = AKOperation.parameters(1)

let fattenOperation = AKStereoOperation(
    "\(input) dup \(1 - fattenMixParameter) * swap 0 \(fattenTimeParameter) 1.0 vdelay \(fattenMixParameter) * +")
let fatten = AKOperationEffect(player, stereoOperation: fattenOperation)

AudioKit.output = fatten
AudioKit.start()

player.play()

fatten.parameters = [0.1, 0.5]

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var timeLabel: Label?
    var mixLabel: Label?

    override func setup() {
        addTitle("Analog Synth X Fatten")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        timeLabel = addLabel("Time: \(fatten.parameters[0])")
        addSlider(#selector(setTime), value: fatten.parameters[0], minimum: 0.03, maximum: 0.1)

        mixLabel = addLabel("Mix: \(fatten.parameters[0])")
        addSlider(#selector(setMix), value: fatten.parameters[1])
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav",  fromBaseDirectory: .resources)
        try? player.replaceFile(file!)
        player.play()
    }

    func startDrumLoop() {
        startLoop("drum")
    }

    func startBassLoop() {
        startLoop("bass")
    }

    func startGuitarLoop() {
        startLoop("guitar")
    }

    func startLeadLoop() {
        startLoop("lead")
    }

    func startMixLoop() {
        startLoop("mix")
    }

    func stop() {
        player.stop()
    }

    func setTime(slider: Slider) {
        fatten.parameters = [Double(slider.value), fatten.parameters[1]]
        timeLabel!.text = "Time: \(String(format: "%0.3f", fatten.parameters[0]))"
    }

    func setMix(slider: Slider) {
        fatten.parameters = [fatten.parameters[0], Double(slider.value)]
        mixLabel!.text = "Mix: \(String(format: "%0.3f", fatten.parameters[1]))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@nex