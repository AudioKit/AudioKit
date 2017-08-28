//: ## Stereo Field Limiter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
var player = try AKAudioPlayer(file: file)
player.looping = true

var limitedOutput = AKStereoFieldLimiter(player)

AudioKit.output = limitedOutput
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Stereo Field Limiter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: limitedOutput))

        addSubview(AKPropertySlider(property: "Amount", value: limitedOutput.amount) { sliderValue in
            limitedOutput.amount = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
