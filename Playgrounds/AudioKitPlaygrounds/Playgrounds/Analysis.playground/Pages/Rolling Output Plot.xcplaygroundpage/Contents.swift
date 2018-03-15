//: ## Rolling Output Plot
//:  If you open the Assitant editor and make sure it shows the
//: "Rolling Output Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the amplitude peaks scrolling in the view
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav")

let player = AKPlayer(audioFile: file)
player.isLooping = true

var variSpeed = AKVariSpeed(player)
variSpeed.rate = 2.0

AudioKit.output = variSpeed
try AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Playback Speed")

        addView(AKSlider(property: "Rate", value: variSpeed.rate, range: 0.312_5 ... 5) { sliderValue in
            variSpeed.rate = sliderValue
        })

        addView(AKRollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
