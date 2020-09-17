//: ## Stereo Field Limiter
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var limitedOutput = StereoFieldLimiter(player)

engine.output = limitedOutput
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Stereo Field Limiter")

        addView(Button(title: "Stop") { button in
            let node = limitedOutput
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop" : "Start"
        })

        addView(Slider(property: "Amount", value: limitedOutput.amount) { sliderValue in
            limitedOutput.amount = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
