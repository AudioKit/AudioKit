//: ## Delay
//: Exploring the powerful effect of repeating sounds after
//: varying length delay times and feedback amounts
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKDelay(player)
delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.wetDryMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    var timeSlider: AKPropertySlider?
    var feedbackSlider: AKPropertySlider?
    var lowPassCutoffFrequencySlider: AKPropertySlider?
    var wetDryMixSlider: AKPropertySlider?

    override func setup() {
        addTitle("Delay")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        timeSlider = AKPropertySlider(
            property: "Time",
            value: delay.time,
            color: AKColor.green
        ) { sliderValue in
            delay.time = sliderValue
            }
        addSubview(timeSlider!)

        feedbackSlider = AKPropertySlider(
            property: "Feedback",
            value: delay.feedback,
            color: AKColor.red
        ) { sliderValue in
            delay.feedback = sliderValue
        }
        addSubview(feedbackSlider!)

        lowPassCutoffFrequencySlider = AKPropertySlider(
            property: "Low Pass Cutoff",
            value: delay.lowPassCutoff, maximum: 22050,
            color: AKColor.magenta
        ) { sliderValue in
            delay.lowPassCutoff = sliderValue
        }
        addSubview(lowPassCutoffFrequencySlider!)

        wetDryMixSlider = AKPropertySlider(
            property: "Mix",
            value: delay.wetDryMix,
            color: AKColor.cyan
        ) { sliderValue in
            delay.wetDryMix = sliderValue
        }
        addSubview(wetDryMixSlider!)

        let presets = ["Short","Dense Long", "Electric Circuits"]
        addSubview(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Short":
                delay.presetShortDelay()
            case "Dense Long":
                delay.presetDenseLongDelay()
            case "Electric Circuits":
                delay.presetElectricCircuitsDelay()
            default: break
            }
            self.updateUI()
            }
        )
    }

    func updateUI() {
        timeSlider?.value = delay.time
        feedbackSlider?.value = delay.feedback
        lowPassCutoffFrequencySlider?.value = delay.lowPassCutoff
        wetDryMixSlider?.value = delay.wetDryMix
    }

}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
