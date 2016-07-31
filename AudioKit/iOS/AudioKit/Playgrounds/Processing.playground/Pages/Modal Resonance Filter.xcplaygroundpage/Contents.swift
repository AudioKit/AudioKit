//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
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

    override func setup() {
        addTitle("Modal Resonance Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.1f Hz",
            value: filter.frequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            filter.frequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Quality Factor",
            format: "%0.1f",
            value: filter.qualityFactor, minimum: 0.1, maximum: 20,
            color: AKColor.redColor()
        ) { sliderValue in
            filter.qualityFactor = sliderValue
            })

    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
