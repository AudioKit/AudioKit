//: ## String Resonator
//: ##
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var stringResonator = AKStringResonator(player)
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 1_000
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
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Fundamental Frequency",
            format: "%0.1f Hz",
            value: stringResonator.fundamentalFrequency, maximum: 5_000,
            color: AKColor.green
        ) { sliderValue in
            stringResonator.fundamentalFrequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Feedback",
            value: stringResonator.feedback,
            color: AKColor.red
        ) { sliderValue in
            stringResonator.feedback = sliderValue
            })
    }

}
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
