//: ## Pitch Shift Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let sinusoid = AKOperation.sineWave(frequency: parameters[2])
    let shift = parameters[0] + sinusoid * parameters[1] / 2.0
    return player.pitchShift(semitones: shift)
}
effect.parameters = [0, 7, 3]

engine.output = effect
try engine.start()
player.play()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Pitch Shift Operation")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Base Shift",
                         value: effect.parameters[0],
                         range: -12 ... 12,
                         format: "%0.3f semitones"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addView(AKSlider(property: "Range",
                         value: effect.parameters[1],
                         range: 0 ... 24,
                         format: "%0.3f semitones"
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addView(AKSlider(property: "Speed",
                         value: effect.parameters[2],
                         range: 0.001 ... 10,
                         format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
