//: ## Pitch Shifter
//: With AKTimePitch you can easily change the pitch and speed of a
//: player-generated sound.  It does not work on live input or generated signals.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
var player = AKPlayer(audioFile: file)
player.isLooping = true

var pitchshifter = AKPitchShifter(player)

AudioKit.output = pitchshifter
try AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Pitch Shifter")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Pitch Shifter") { button in
            let node = pitchshifter
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Pitch Shifter" : "Start Pitch Shifter"
        })

        addView(AKSlider(property: "Pitch",
                         value: pitchshifter.shift,
                         range: -24 ... 24,
                         format: "%0.3f Semitones"
        ) { sliderValue in
            pitchshifter.shift = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
