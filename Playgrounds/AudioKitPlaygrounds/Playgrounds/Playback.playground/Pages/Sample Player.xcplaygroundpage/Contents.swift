//: ## Sample Player
//: An alternative to AKSampler or AKAudioPlayer, AKSamplePlayer is a player that
//: doesn't rely on an as much Apple AV foundation/engine code as the others.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "alphabet.mp3", baseDir: .resources)

let samplePlayer = AKSamplePlayer(file: file) {
    print("Playback completed.")
}

AudioKit.output = samplePlayer
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    var current = 0
    override func setup() {
        addTitle("Sample Player")

        addSubview(AKButton(title: "Play") {
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(40_000))
            return "Play"
        })
        
        addSubview(AKButton(title: "Play Reversed") {
            let start = Sample(44_100 * (self.current % 26))
            samplePlayer.play(from: start + 40_000, to: start)
            return "Play Reversed"
        })
        addSubview(AKButton(title: "Next") {
            self.current += 1
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(40_000))
            return "Next"
        })
        addSubview(AKButton(title: "Previous") {
            self.current -= 1
            if self.current < 0 {
                self.current += 26
            }
            samplePlayer.play(from: Sample(44_100 * (self.current % 26)),
                              length: Sample(40_000))
            return "Previous"
        })

        addSubview(AKPropertySlider(
        property: "Rate",
        value: 1, minimum: 0.1, maximum: 2) {
                sliderValue in
            samplePlayer.rate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
