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

metronome.callback = {
    view.beatFlasher.value = 1.0
    view.beatFlasher.property = "Beat \(metronome.currentBeat)"
    
    DispatchQueue.main.async {
        view.beatFlasher.needsDisplay = true
    }
    
    let deadlineTime = DispatchTime.now() + (60 / metronome.tempo) / 10.0
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        view.beatFlasher.value = 0.0
    }
}

AudioKit.output = metronome
AudioKit.start()
metronome.start()

class PlaygroundView: AKPlaygroundView {
    
    var beatFlasher: AKPropertySlider!
    
    override func setup() {
        addTitle("Metronome")
        
        beatFlasher = AKPropertySlider(
            property: "",
            value: 0,
            color: AKColor.yellow
        ) { _ in
            // Nothing
        }
        addSubview(beatFlasher)
        
        addSubview(AKButton(title: "Stop", color: AKColor.red) {
            metronome.stop()
            metronome.reset()
            return ""
        })
        
        addSubview(AKButton(title: "Start") {
            metronome.reset()
            metronome.restart()
            return ""
        })
        
        addSubview(AKPropertySlider(
            property: "Sudivision",
            format: "%0.0f",
            value: 4, minimum: 1, maximum: 10,
            color: AKColor.red
        ) { sliderValue in
            metronome.subdivision = Int(round(sliderValue))
        })
        
        addSubview(AKPropertySlider(
            property: "Tempo",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240,
            color: AKColor.green
        ) { sliderValue in
            metronome.tempo = sliderValue
        })
    }
}

let view = PlaygroundView()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
