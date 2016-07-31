//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Delay
//: ### Exploring the powerful effect of repeating sounds after
//: ### varying length delay times and feedback amounts
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    var timeSlider: AKPropertySlider?
    var feedbackSlider: AKPropertySlider?
    var lowPassCutoffFrequencySlider: AKPropertySlider?
    var dryWetMixSlider: AKPropertySlider?

    override func setup() {
        addTitle("Delay")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: audioResourceFileNames))

        timeSlider = AKPropertySlider(
            property: "Time",
            value: delay.time,
            color: AKColor.greenColor()
        ) { sliderValue in
            delay.time = sliderValue
            }
        addSubview(timeSlider!)

        feedbackSlider = AKPropertySlider(
            property: "Feedback",
            value: delay.feedback,
            color: AKColor.redColor()
        ) { sliderValue in
            delay.feedback = sliderValue
        }
        addSubview(feedbackSlider!)

        lowPassCutoffFrequencySlider = AKPropertySlider(
            property: "Low Pass Cutoff",
            value: delay.lowPassCutoff, maximum: 22050,
            color: AKColor.magentaColor()
        ) { sliderValue in
            delay.lowPassCutoff = sliderValue
        }
        addSubview(lowPassCutoffFrequencySlider!)

        dryWetMixSlider = AKPropertySlider(
            property: "Mix",
            value: delay.dryWetMix,
            color: AKColor.cyanColor()
        ) { sliderValue in
            delay.dryWetMix = sliderValue
        }
        addSubview(dryWetMixSlider!)

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
        dryWetMixSlider?.value = delay.dryWetMix
    }

}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
