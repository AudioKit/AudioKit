//: ## Stereo Field Limiter
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)
var player = try AKAudioPlayer(file: file)
player.looping = true

var limitedOutput = AKStereoFieldLimiter(player)

AudioKit.output = limitedOutput
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Stereo Field Limiter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: limitedOutput))

        addSubview(AKPropertySlider(
            property: "Amount",
            format: "%0.3f",
            value: limitedOutput.amount,
            color: AKColor.green
        ) { sliderValue in
            limitedOutput.amount = sliderValue
        })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
