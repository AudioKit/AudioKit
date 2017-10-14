//: ## Tanh Distortion
//: ##
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var distortion = AKTanhDistortion(player)
distortion.pregain = 1.0
distortion.postgain = 1.0
distortion.postiveShapeParameter = 1.0
distortion.negativeShapeParameter = 1.0

AudioKit.output = distortion
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Tanh Distortion")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Distortion") { button in
            let node = distortion
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Distortion" : "Start Distortion"
        })

        addView(AKSlider(property: "Pre-gain", value: distortion.pregain, range: 0 ... 10) { sliderValue in
            distortion.pregain = sliderValue
        })

        addView(AKSlider(property: "Post-gain", value: distortion.postgain, range: 0 ... 10) { sliderValue in
            distortion.postgain = sliderValue
        })

        addView(AKSlider(property: "Postive Shape Parameter",
                         value: distortion.postiveShapeParameter,
                         range: -10 ... 10
        ) { sliderValue in
            distortion.postiveShapeParameter = sliderValue
        })

        addView(AKSlider(property: "Negative Shape Parameter",
                         value: distortion.negativeShapeParameter,
                         range: -10 ... 10
        ) { sliderValue in
            distortion.negativeShapeParameter = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
