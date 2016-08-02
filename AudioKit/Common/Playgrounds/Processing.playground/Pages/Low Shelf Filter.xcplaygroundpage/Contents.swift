//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Shelf Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowShelfFilter = AKLowShelfFilter(player)
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

AudioKit.output = lowShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Shelf Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: lowShelfFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: lowShelfFilter.cutoffFrequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            lowShelfFilter.cutoffFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Gain",
            format: "%0.1f dB",
            value: lowShelfFilter.gain, minimum: -40, maximum: 40,
            color: AKColor.redColor()
        ) { sliderValue in
            lowShelfFilter.gain = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
