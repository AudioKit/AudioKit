//: ## Rolling Output Plot
//:  If you open the Assitant editor and make sure it shows the
//: "Rolling Output Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the amplitude peaks scrolling in the view
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav")

let player = try AKAudioPlayer(file: file)
player.looping = true

var variSpeed = AKVariSpeed(player)
variSpeed.rate = 2.0

AudioKit.output = variSpeed
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Playback Speed")

        addSubview(AKPropertySlider(property: "Rate", value: variSpeed.rate, range: 0.312_5 ... 5) { sliderValue in
            variSpeed.rate = sliderValue
        })

        addSubview(AKRollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
