//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Resonant Filter
//:
import XCPlayground
import AudioKit

let file = try? AKAudioFile(readFileName: audioResourceFileNames[0],
                            baseDir: .Resources)

let player = try AKAudioPlayer(file: file!)
player.looping = true

var filter = AKResonantFilter(player)
filter.frequency = 5000 // Hz
filter.bandwidth = 600  // Cents

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Resonant Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.1f Hz",
            value: filter.frequency, minimum: 20, maximum: 22050,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.frequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Bandwidth",
            format: "%0.1f Hz",
            value: filter.bandwidth, minimum: 100, maximum: 1200,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.bandwidth = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
