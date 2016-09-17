//: ## Node Output Plot
//: What's interesting here is that we're plotting the waveform BEFORE the delay is processed
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKDelay(player)

delay.time = 0.1 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()


public class PlaygroundView: AKPlaygroundView {
    public override func setup() {
        addTitle("Node Output Plots")

        addSubview(AKPropertySlider(
            property: "Time",
            value: delay.time,
            color: AKColor.green
        ) { sliderValue in
            delay.time = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Feedback",
            value: delay.feedback,
            color: AKColor.red
        ) { sliderValue in
            delay.feedback = sliderValue
        })

        addLabel("This is the output of the player")
        let plot = AKNodeOutputPlot(player, frame: CGRect.init(x: 0, y: 0, width: 440, height: 300))
        plot.plotType = .Rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = AKColor.blue
        addSubview(plot)

        addLabel("This is the output of the delay")
        let plot2 = AKNodeOutputPlot(delay, frame: CGRect.init(x: 0, y: 0, width: 440, height: 300))
        plot2.plotType = .Rolling
        plot2.shouldFill = true
        plot2.shouldMirror = true
        plot2.color = AKColor.red
        addSubview(plot2)
    }
}


PlaygroundPage.current.liveView = PlaygroundView()
PlaygroundPage.current.needsIndefiniteExecution = true
