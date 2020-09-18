//: ## Time Stretching and Pitch Shifting
//: With TimePitch you can easily change the pitch and speed of a
//: player-generated sound.  It does not work on live input or generated signals.
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var timePitch = TimePitch(player)
timePitch.rate = 2.0
timePitch.pitch = -400.0
timePitch.overlap = 8.0

engine.output = timePitch
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Time/Pitch")

        addLabel("Time/Pitch Parameters")

        addView(Button(title: "Stop Stretching") { button in
            let node = timePitch
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Stretching" : "Start Stretching"
        })

        addView(Slider(property: "Rate", value: timePitch.rate, range: 0.312_5 ... 5) { sliderValue in
            timePitch.rate = sliderValue
        })

        addView(Slider(property: "Pitch",
                         value: timePitch.pitch,
                         range: -2_400 ... 2_400,
                         format: "%0.3f Cents"
        ) { sliderValue in
            timePitch.pitch = sliderValue
        })

        addView(Slider(property: "Overlap", value: timePitch.overlap, range: 3 ... 32) { sliderValue in
            timePitch.overlap = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
