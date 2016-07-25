//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Resonant Filter
//:
import XCPlayground
import AudioKit

let file = try? AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file!)
player.looping = true

//: Next, we'll connect the audio sources to a Resonant filter
var resonantFilter = AKResonantFilter(player)

//: Set the parameters of the Resonant filter here
resonantFilter.frequency = 5000 // Hz
resonantFilter.bandwidth = 600  // Cents

AudioKit.output = resonantFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var centerFrequencyLabel: Label?
    var bandwidthLabel: Label?

    override func setup() {
        addTitle("Resonant Filter")

        addButtons()

        addLabel("Resonant Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        centerFrequencyLabel = addLabel("Center Frequency: \(resonantFilter.frequency) Hz")
        addSlider(#selector(setCenterFrequency),
                  value: resonantFilter.frequency,
                  minimum: 20,
                  maximum: 22050)

        bandwidthLabel = addLabel("Bandwidth \(resonantFilter.bandwidth) Cents")
        addSlider(#selector(setBandwidth),
                  value: resonantFilter.bandwidth,
                  minimum: 100,
                  maximum: 12000)
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

    func process() {
        resonantFilter.play()
    }

    func bypass() {
        resonantFilter.bypass()
    }

    func setCenterFrequency(slider: Slider) {
        resonantFilter.frequency = Double(slider.value)
        let frequency = String(format: "%0.1f", resonantFilter.frequency)
        centerFrequencyLabel!.text = "Center Frequency: \(frequency) Hz"
    }

    func setBandwidth(slider: Slider) {
        resonantFilter.bandwidth = Double(slider.value)
        let bandwidth = String(format: "%0.1f", resonantFilter.bandwidth)
        bandwidthLabel!.text = "Bandwidth: \(bandwidth) Cents"
    }
}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
