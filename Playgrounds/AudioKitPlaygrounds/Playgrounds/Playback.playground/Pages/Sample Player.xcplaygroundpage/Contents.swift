//: ## Sample Player
//: An alternative to AKAppleSampler or AKAudioPlayer, AKSamplePlayer is a player that
//: doesn't rely on an as much Apple AV foundation/engine code as the others.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "alphabet.mp3")

let samplePlayer = AKSamplePlayer(file: file) {
    AKLog("Playback completed.")
}

engine.output = samplePlayer
try engine.start()

import AudioKitUI

class LiveView: AKLiveViewController {

    var current = 0
    override func viewDidLoad() {
        addTitle("Sample Player")

        addView(AKButton(title: "Play") { _ in
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(44_100))
        })

        addView(AKButton(title: "Play Reversed") { _ in
            let start = Sample(44_100 * (self.current % 26))
            samplePlayer.play(from: start + 44_100, to: start)
        })

        addView(AKButton(title: "Next") { _ in
            self.current += 1
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(44_100))
        })

        addView(AKButton(title: "Previous") { _ in
            self.current -= 1
            if self.current < 0 {
                self.current += 26
            }
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(40_000))
        })

        addView(AKSlider(property: "Rate", value: 1, range: 0.1 ... 2) { sliderValue in
            samplePlayer.rate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
