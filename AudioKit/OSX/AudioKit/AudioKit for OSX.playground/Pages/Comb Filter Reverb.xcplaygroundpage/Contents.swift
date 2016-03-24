//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Comb Filter Reverb
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var filter = AKCombFilterReverb(player, loopDuration: 0.1)

//: Set the parameters of the Comb Filter here
filter.reverbDuration = 1

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var durationLabel: Label?

    override func setup() {
        addTitle("Comb Filter Reverb")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        durationLabel = addLabel("Duration: \(filter.reverbDuration)")
        addSlider(#selector(self.setDuration(_:)), value: filter.reverbDuration, minimum: 0, maximum: 5)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setDuration(slider: Slider) {
        filter.reverbDuration = Double(slider.value)
        durationLabel!.text = "Duration: \(String(format: "%0.3f", filter.reverbDuration))"
        filter.reverbDuration // to plot value history
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
