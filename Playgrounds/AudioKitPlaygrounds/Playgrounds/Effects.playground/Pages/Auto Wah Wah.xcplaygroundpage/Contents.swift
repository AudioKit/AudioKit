//: ## Auto Wah Wah
//: One of the most iconic guitar effects is the wah-pedal.
//: This playground runs an audio loop of a guitar through an AKAutoWah node.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var wah = AKAutoWah(player)
wah.wah = 1
wah.amplitude = 1

AudioKit.output = wah
try AudioKit.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Auto Wah Wah")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Wah", value: wah.wah) { sliderValue in
            wah.wah = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
