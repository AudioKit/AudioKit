//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulator
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var ringModulator = AKRingModulator(player)
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

AudioKit.output = ringModulator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Ring Modulator")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        addSubview(AKBypassButton(node: ringModulator))

        addSubview(AKPropertySlider(
            property: "Frequency 1",
            format: "%0.2f Hz",
            value: ringModulator.frequency1, minimum: 0.5, maximum: 8000,
            color: AKColor.greenColor()
            ) { sliderValue in
                ringModulator.frequency1 = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Frequency 2",
            format: "%0.2f Hz",
            value: ringModulator.frequency2, minimum: 0.5, maximum: 8000,
            color: AKColor.greenColor()
        ) { sliderValue in
            ringModulator.frequency2 = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Balance",
            value: ringModulator.balance,
            color: AKColor.redColor()
        ) { sliderValue in
            ringModulator.balance = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Mix",
            value: ringModulator.mix,
            color: AKColor.cyanColor()
        ) { sliderValue in
            ringModulator.mix = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
