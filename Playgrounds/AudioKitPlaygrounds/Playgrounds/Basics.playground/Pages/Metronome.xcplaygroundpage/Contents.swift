//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Metronome
//:
//: A metronome is a basic function that plays beeps and calls a callback on every beat.
import AudioKitPlaygrounds
import AudioKit

let metronome = AKMetronome()
let view = PlaygroundView()

metronome.callback = {
    view.beatFlasher.color = .white

    DispatchQueue.main.async {
        view.beatFlasher.needsDisplay = true
    }

    let deadlineTime = DispatchTime.now() + (60 / metronome.tempo) / 10.0
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        view.beatFlasher.color = .red
    }
}

AudioKit.output = metronome
AudioKit.start()
metronome.start()

class PlaygroundView: AKPlaygroundView {

    var beatFlasher: AKButton!

    override func setup() {
        addTitle("Metronome")

        beatFlasher =  AKButton(title: "Stop", color: AKColor.red) { button in
            if metronome.isPlaying {
                button.title = "Start"
                button.color = #colorLiteral(red: 0, green: 0.5859588462, blue: 0, alpha: 1)
                metronome.stop()
                metronome.reset()
            } else {
                button.title = "Stop"
                button.color = .red
                metronome.reset()
                metronome.restart()
            }
        }

        addSubview(beatFlasher)

        addSubview(AKPropertySlider(
            property: "Sudivision",
            format: "%0.0f",
            value: 4, minimum: 1, maximum: 10
        ) { sliderValue in
            metronome.subdivision = Int(round(sliderValue))
        })

        addSubview(AKPropertySlider(
            property: "Tempo",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240
        ) { sliderValue in
            metronome.tempo = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Frequency 1",
            format: "%0.1f Hz",
            value: 2_000, minimum: 200, maximum: 4_000
        ) { sliderValue in
            metronome.frequency1 = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Frequency 2",
            format: "%0.1f Hz",
            value: 1_000, minimum: 200, maximum: 4_000
        ) { sliderValue in
            metronome.frequency2 = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
