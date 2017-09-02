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

import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    var beatFlasher: AKButton!

    override func setup() {
        addTitle("Metronome")

        beatFlasher = AKButton(title: "Stop", color: AKColor.red) { button in
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

        addSubview(AKSlider(property: "Sudivision",
                            value: 4,
                            range: 1 ... 10,
                            format: "%0.0f"
        ) { sliderValue in
            metronome.subdivision = Int(round(sliderValue))
        })

        addSubview(AKSlider(property: "Tempo",
                            value: 60,
                            range: 40 ... 240,
                            format: "%0.1f BPM"
        ) { sliderValue in
            metronome.tempo = sliderValue
        })

        addSubview(AKSlider(property: "Frequency 1",
                            value: 2_000,
                            range: 200 ... 4_000,
                            format: "%0.0f Hz"
        ) { sliderValue in
            metronome.frequency1 = sliderValue
        })

        addSubview(AKSlider(property: "Frequency 2",
                            value: 1_000,
                            range: 200 ... 4_000,
                            format: "%0.0f Hz"
        ) { sliderValue in
            metronome.frequency2 = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
