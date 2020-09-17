//: ## Playback Speed
//: This playground uses the VariSpeed node to change the playback speed of a file
//: (which also affects the pitch)
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AudioPlayer(file: file)
player.looping = true

var variSpeed = VariSpeed(player)
variSpeed.rate = 2.0

engine.output = variSpeed
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Playback Speed")

        addView(Button(title: "Stop Effect") { button in
            let node = variSpeed
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Effect" : "Start Effect"
        })

        addView(Slider(property: "Rate", value: variSpeed.rate, range: 0.312_5 ... 5) { sliderValue in
            variSpeed.rate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
