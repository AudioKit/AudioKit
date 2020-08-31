//: ## 3D Panner
//: ###
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

let panner = AK3DPanner(player)

engine.output = panner
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("3D Panner")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "X", value: panner.x, range: -10 ... 10) { sliderValue in
            panner.x = sliderValue
        })

        addView(AKSlider(property: "Y", value: panner.y, range: -10 ... 10) { sliderValue in
            panner.y = sliderValue
        })

        addView(AKSlider(property: "Z", value: panner.z, range: -10 ... 10) { sliderValue in
            panner.z = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
