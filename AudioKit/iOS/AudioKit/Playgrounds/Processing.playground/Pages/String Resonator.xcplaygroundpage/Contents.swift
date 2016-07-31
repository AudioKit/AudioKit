//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## String Resonator
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var stringResonator = AKStringResonator(player)

//: Set the parameters of the String Resonator here.
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 1000
stringResonator.rampTime = 0.1

AudioKit.output = stringResonator
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("String Resonator")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        addSubview(AKPropertySlider(
            property: "Fundamental Frequency",
            format: "%0.1f Hz",
            value: stringResonator.fundamentalFrequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            stringResonator.fundamentalFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Feedback",
            value: stringResonator.feedback,
            color: AKColor.redColor()
        ) { sliderValue in
            stringResonator.feedback = sliderValue
            })
    }


}
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
