//: ## Stereo Field Limiter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
var player = AKPlayer(audioFile: file)
player.isLooping = true

var limitedOutput = AKStereoFieldLimiter(player)

AudioKit.output = limitedOutput
try AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Stereo Field Limiter")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop") { button in
            let node = limitedOutput
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop" : "Start"
        })

        addView(AKSlider(property: "Amount", value: limitedOutput.amount) { sliderValue in
            limitedOutput.amount = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
