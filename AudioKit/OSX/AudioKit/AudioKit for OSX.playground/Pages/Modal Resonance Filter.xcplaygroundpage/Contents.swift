//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var filter = AKModalResonanceFilter(player)

filter.frequency = 300 // Hz
filter.qualityFactor = 20

let balancedOutput = AKBalancer(filter, comparator: player)
AudioKit.output = balancedOutput
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var qualityFactorLabel: Label?

    override func setup() {
        addTitle("Modal Resonance Filter")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        frequencyLabel = addLabel("Frequency: \(filter.frequency)")
        addSlider(#selector(self.setFrequency(_:)), value: filter.frequency, minimum: 0, maximum: 5000)

        qualityFactorLabel = addLabel("Quality Factor: \(filter.qualityFactor)")
        addSlider(#selector(self.setQualityFactor(_:)), value: filter.qualityFactor, minimum: 0, maximum: 20)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setFrequency(slider: Slider) {
        filter.frequency = Double(slider.value)
        frequencyLabel!.text = "Frequency: \(String(format: "%0.0f", filter.frequency))"
    }

    func setQualityFactor(slider: Slider) {
        filter.qualityFactor = Double(slider.value)
        qualityFactorLabel!.text = "Quality Factor: \(String(format: "%0.1f", filter.qualityFactor))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
