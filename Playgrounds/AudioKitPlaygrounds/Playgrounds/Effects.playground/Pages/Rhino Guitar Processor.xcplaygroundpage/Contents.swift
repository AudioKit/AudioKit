//: ## Rhino Guitar Processor

import AudioKitPlaygrounds
import AudioKit

var rhino: AKRhinoGuitarProcessor!

do {
    let guitarFile = try AKAudioFile(readFileName: "guitar.wav")

    let player = try AKAudioPlayer(file: guitarFile)
    player.looping = true
    rhino = AKRhinoGuitarProcessor(player)
    let reverb = AKReverb(rhino)
    engine.output = AKMixer(reverb, rhino)
    try engine.start()
    player.play()
} catch let error as NSError {
    AKLog(error.localizedDescription)
}
//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Rhino Guitar Processor")

        addView(AKButton(title: "Stop Rhino") { button in
            rhino.isStarted ? rhino.stop() : rhino.play()
            button.title = rhino.isStarted ? "Stop Rhino" : "Start Rhino"
        })

        addView(AKSlider(property: "Pre Gain",
                         value: rhino.preGain,
                         range: 0.0 ... 10.0,
                         format: "%0.2f"
        ) { sliderValue in
            rhino.preGain = sliderValue
        })

        addView(AKSlider(property: "Dist. Amount",
                         value: rhino.distortion,
                         range: 1.0 ... 20.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.distortion = sliderValue
        })

        addView(AKSlider(property: "Lows",
                         value: rhino.lowGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.lowGain = sliderValue
        })

        addView(AKSlider(property: "Mids",
                         value: rhino.midGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.midGain = sliderValue
        })

        addView(AKSlider(property: "Highs",
                         value: rhino.highGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.highGain = sliderValue
        })

        addView(AKSlider(property: "Output Gain",
                         value: rhino.postGain,
                         range: 0.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.postGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
