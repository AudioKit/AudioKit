//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## 3D Panner
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let panner = AK3DPanner(player)

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

        addButtons()

        addLabel("Parameters")


        xLabel = addLabel("x: \(panner.x)")
        addSlider(#selector(setX), value: Double(panner.x), minimum: -10, maximum: 10)

        yLabel = addLabel("y: \(panner.y)")
        addSlider(#selector(setY), value: Double(panner.y), minimum: -10, maximum: 10)

        zLabel = addLabel("z: \(panner.z)")
        addSlider(#selector(setZ), value: Double(panner.z), minimum: -10, maximum: 10)

    }

    //: Handle UI Events

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
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

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
