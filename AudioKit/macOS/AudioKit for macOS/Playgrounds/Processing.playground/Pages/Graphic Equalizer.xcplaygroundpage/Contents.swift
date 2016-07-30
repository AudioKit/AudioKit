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
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Graphic Equalizer")

        addButtons()

        addLabel("Equalizer Gains")

        addSubview(AKPropertySlider(
            property: "Low",
            value: lowFilter.gain, maximum: 10,
            color: AKColor.redColor()
        ) { sliderValue in
            lowFilter.gain = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "Mid",
            value: midFilter.gain, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            midFilter.gain = sliderValue
            })
        
        addSubview(AKPropertySlider(
            property: "High",
            value: highFilter.gain, maximum: 10,
            color: AKColor.cyanColor()
        ) { sliderValue in
            highFilter.gain = sliderValue
            })
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
}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
