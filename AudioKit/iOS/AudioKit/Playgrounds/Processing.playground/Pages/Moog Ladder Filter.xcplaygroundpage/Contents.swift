//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter
//: ### One of the coolest filters available in AudioKit is the Moog Ladder.
//: ### It's based off of Robert Moog's iconic ladder filter, which was the
//: ### first implementation of a voltage - controlled filter used in an
//: ### analog synthesizer. As such, it was the first filter that gave the
//: ### ability to use voltage control to determine the cutoff frequency of the
//: ### filter. As we're dealing with a software implementation, and not an
//: ### analog synthesizer, we don't have to worry about dealing with
//: ### voltage control directly. However, by using this node, you can
//: ### emulate some of the sounds of classic analog synthesizers in your app.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var moogLadder = AKMoogLadder(player)
moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6

AudioKit.output = moogLadder
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Moog Ladder Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: moogLadder.cutoffFrequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            moogLadder.cutoffFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Resonance",
            format: "%0.2f",
            value: moogLadder.resonance,
            color: AKColor.redColor()
        ) { sliderValue in
            moogLadder.resonance = sliderValue
            })
    }


}
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
