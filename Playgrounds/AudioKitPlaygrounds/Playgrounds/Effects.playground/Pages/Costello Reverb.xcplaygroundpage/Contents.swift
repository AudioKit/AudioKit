//: ## Sean Costello Reverb
//: This is a great sounding reverb that we just love.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

var reverb = AKCostelloReverb(player)
reverb.cutoffFrequency = 9_900 // Hz
reverb.feedback = 0.92

AudioKit.output = reverb
try AudioKit.start()

player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    var cutoffFrequencySlider: AKSlider!
    var feedbackSlider: AKSlider!

    override func viewDidLoad() {
        addTitle("Sean Costello Reverb")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        cutoffFrequencySlider = AKSlider(property: "Cutoff Frequency",
                                         value: reverb.cutoffFrequency,
                                         range: 20 ... 5_000,
                                         format: "%0.1f Hz"
        ) { sliderValue in
            reverb.cutoffFrequency = sliderValue
        }
        addView(cutoffFrequencySlider)

        feedbackSlider = AKSlider(property: "Feedback", value: reverb.feedback) { sliderValue in
            reverb.feedback = sliderValue
        }
        addView(feedbackSlider)

        let presets = ["Short Tail", "Low Ringing Tail"]
        addView(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Short Tail":
                reverb.presetShortTailCostelloReverb()
            case "Low Ringing Tail":
                reverb.presetLowRingingLongTailCostelloReverb()
            default:
                break
            }
            self.updateUI()
        })
    }

    func updateUI() {
        cutoffFrequencySlider?.value = reverb.cutoffFrequency
        feedbackSlider?.value = reverb.feedback
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
