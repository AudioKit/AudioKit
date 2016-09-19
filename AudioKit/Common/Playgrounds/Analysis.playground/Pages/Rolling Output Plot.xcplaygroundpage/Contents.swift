//: ## Rolling Output Plot
//:  If you open the Assitant editor and make sure it shows the
//: "Rolling Output Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the amplitude peaks scrolling in the view
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)

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

        addSubview(AKPropertySlider(
            property: "Rate",
            format: "%0.3f",
            value: variSpeed.rate, minimum: 0.3125, maximum: 5,
            color: AKColor.green
        ) { sliderValue in
            variSpeed.rate = sliderValue
            })

        addSubview(AKRollingOutputPlot.createView())
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
