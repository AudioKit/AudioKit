//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb
//: ### This is a great sounding reverb that we just love.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var reverb = AKCostelloReverb(player)

//: Set the parameters of the reverb here
reverb.cutoffFrequency = 9900 // Hz
reverb.feedback = 0.92

AudioKit.output = reverb
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencySlider: AKPropertySlider?
    var feedbackSlider: AKPropertySlider?

    override func setup() {
        addTitle("Sean Costello Reverb")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: AKPlaygroundView.audioResourceFileNames))

        cutoffFrequencySlider = AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: reverb.cutoffFrequency, maximum: 5000,
            color: AKColor.greenColor()
        ) { sliderValue in
            reverb.cutoffFrequency = sliderValue
            }
        addSubview(cutoffFrequencySlider!)


        feedbackSlider = AKPropertySlider(
            property: "Feedback",
            value: reverb.feedback,
            color: AKColor.redColor()
        ) { sliderValue in
            reverb.feedback = sliderValue
            }
        addSubview(feedbackSlider!)

        let presets = ["Short Tail", "Low Ringing Tail"]
        addSubview(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Short Tail":
                reverb.presetShortTailCostelloReverb()
            case "Low Ringing Tail":
                reverb.presetLowRingingLongTailCostelloReverb()
            default: break
            }
            self.updateUI()
            }
        )
    }

    func updateUI() {
        cutoffFrequencySlider?.value = reverb.cutoffFrequency
        feedbackSlider?.value = reverb.feedback
    }

}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
