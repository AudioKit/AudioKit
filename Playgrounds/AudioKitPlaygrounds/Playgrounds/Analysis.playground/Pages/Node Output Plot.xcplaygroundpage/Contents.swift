//: ## Node Output Plot
//: What's interesting here is that we're plotting the waveform BEFORE the delay is processed
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav")

var player = AKPlayer(audioFile: file)
player.isLooping = true

var delay = AKDelay(player)

delay.time = 0.1 // seconds
delay.feedback = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
try AudioKit.start()
player.play()

import AudioKitUI

public class LiveView: AKLiveViewController {
    public override func viewDidLoad() {
        addTitle("Node Output Plots")

        addView(AKSlider(property: "Time", value: delay.time) { sliderValue in
            delay.time = sliderValue
        })

        addView(AKSlider(property: "Feedback", value: delay.feedback) { sliderValue in
            delay.feedback = sliderValue
        })

        addLabel("This is the output of the player")
        let plot = AKNodeOutputPlot(player, frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = AKColor.blue
        addView(plot)

        addLabel("This is the output of the delay")
        let plot2 = AKNodeOutputPlot(delay, frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        plot2.plotType = .rolling
        plot2.shouldFill = true
        plot2.shouldMirror = true
        plot2.color = AKColor.red
        addView(plot2)
    }
}

import PlaygroundSupport
PlaygroundPage.current.liveView = LiveView()
PlaygroundPage.current.needsIndefiniteExecution = true
