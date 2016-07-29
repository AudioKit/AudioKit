//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Graphic Equalizer
//: ### Here we'll build a graphic equalizer from a set of equalizer filters
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowFilter = AKEqualizerFilter(player, centerFrequency: 50, bandwidth: 100, gain: 1.0)
var midFilter = AKEqualizerFilter(lowFilter, centerFrequency: 350, bandwidth: 300, gain: 1.0)
var highFilter = AKEqualizerFilter(midFilter, centerFrequency: 5000, bandwidth: 1000, gain: 1.0)


AudioKit.output = highFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Graphic Equalizer")

        addButtons()

        addLabel("Equalizer Gains")

        lowLabel = addLabel("Low: \(lowFilter.gain)")
        addSlider(#selector(setLowGain), value: lowFilter.gain, minimum: 0, maximum: 10)

        midLabel = addLabel("Mid: \(midFilter.gain)")
        addSlider(#selector(setMidGain), value: midFilter.gain, minimum: 0, maximum: 10)

        highLabel = addLabel("High: \(highFilter.gain)")
        addSlider(#selector(setHighGain), value: highFilter.gain, minimum: 0, maximum: 10)
    }
    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
    }

    func setLowGain(slider: Slider) {
        lowFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", lowFilter.gain)
        lowLabel!.text = "Low: \(gain)"
    }

    func setMidGain(slider: Slider) {
        midFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", midFilter.gain)
        midLabel!.text = "Mid: \(gain)"
    }

    func setHighGain(slider: Slider) {
        highFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", highFilter.gain)
        highLabel!.text = "High: \(gain)"
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
