//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## 3D Panner
//: ###
import XCPlayground
import AudioKit

let file = try? AKAudioFile(forReadingWithFileName: "mixloop.wav",  fromBaseDirectory: .resources)

let player = try? AKAudioPlayer(file: file!)
player!.looping = true

let panner = AK3DPanner(player!)

AudioKit.output = panner
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var xLabel: Label?
    var yLabel: Label?
    var zLabel: Label?

    override func setup() {
        addTitle("3D Panner")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("Parameters")


        xLabel = addLabel("x: \(panner.x)")
        addSlider(#selector(setX), value: Double(panner.x), minimum: -10, maximum: 10)

        yLabel = addLabel("y: \(panner.y)")
        addSlider(#selector(setY), value: Double(panner.y), minimum: -10, maximum: 10)

        zLabel = addLabel("z: \(panner.z)")
        addSlider(#selector(setZ), value: Double(panner.z), minimum: -10, maximum: 10)

    }

    //: Handle UI Events

    func startLoop(part: String) {
        player!.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav",  fromBaseDirectory: .resources)
        try? player!.replaceFile(file!)
        player!.play()
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
        player!.stop()
    }

    func setX(slider: Slider) {
        panner.x = Double(slider.value)
        xLabel!.text = "x: \(panner.x)"
    }
    func setY(slider: Slider) {
        panner.y = Double(slider.value)
        yLabel!.text = "y: \(panner.y)"

    }
    func setZ(slider: Slider) {
        panner.z = Double(slider.value)
        zLabel!.text = "z: \(panner.z)"

    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previo