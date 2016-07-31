//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the
//: ### high-frequency components of the audio signal, allowing for the
//: ### lower frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowPassFilter = AKLowPassFilter(player)
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        addSubview(AKBypassButton(node: lowPassFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: lowPassFilter.cutoffFrequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            lowPassFilter.cutoffFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Resonance",
            format: "%0.1f dB",
            value: lowPassFilter.resonance, minimum: -20, maximum: 40,
            color: AKColor.redColor()
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
