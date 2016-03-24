//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Decimator
//: ### Decimation is a type of digital distortion like bit crushing, but instead of directly stating what bit depth and sample rate you want, it is done through setting "decimation" and "rounding" parameters.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

//: Next, we'll connect the audio sources to a decimator
var decimator = AKDecimator(player)

//: Set the parameters of the decimator here
decimator.decimation =  0.5 // Normalized Value 0 - 1
decimator.rounding = 0.5 // Normalized Value 0 - 1
decimator.mix = 0.5 // Normalized Value 0 - 1

AudioKit.output = decimator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var decimationLabel: Label?
    var roundingLabel: Label?
    var mixLabel: Label?

    override func setup() {
        addTitle("Decimator")

        addLabel("Audio Player")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        decimationLabel = addLabel("Decimation: \(decimator.decimation)")
        addSlider(#selector(self.setDecimation(_:)), value: decimator.decimation)

        roundingLabel = addLabel("Rounding: \(decimator.rounding)")
        addSlider(#selector(self.setRounding(_:)), value: decimator.rounding)

        mixLabel = addLabel("Mix: \(decimator.mix)")
        addSlider(#selector(self.setMix(_:)), value: decimator.mix)
    }

    //: Handle UI Events

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setDecimation(slider: Slider) {
        decimator.decimation = Double(slider.value)
        let decimation = String(format: "%0.3f", decimator.decimation)
        decimationLabel!.text = "Decimation: \(decimation)"
    }

    func setRounding(slider: Slider) {
        decimator.rounding = Double(slider.value)
        let rounding = String(format: "%0.3f", decimator.rounding)
        roundingLabel!.text = "Rounding: \(rounding)"
    }

    func setMix(slider: Slider) {
        decimator.mix = Double(slider.value)
        let mix = String(format: "%0.3f", decimator.mix)
        mixLabel!.text = "Mix: \(mix)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
