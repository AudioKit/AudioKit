//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var reverb = AKFlatFrequencyResponseReverb(player, loopDuration: 0.1)
reverb.reverbDuration = 1

AudioKit.output = reverb
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Flat Frequency Response Reverb")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Duration",
            value: reverb.reverbDuration, maximum: 5,
            color: AKColor.greenColor()
        ) { sliderValue in
            reverb.reverbDuration = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
