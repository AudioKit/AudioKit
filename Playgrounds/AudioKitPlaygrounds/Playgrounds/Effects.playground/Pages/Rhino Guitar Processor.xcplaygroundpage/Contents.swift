//: ## Rhino Guitar Processor

import AudioKitPlaygrounds
import AudioKit

var rhino: AKRhinoGuitarProcessor!

do {
    let mixloop = try AKAudioFile(readFileName: "guitar.wav")

    let player = try AKAudioPlayer(file: mixloop) {
        print("completion callback has been triggered!")
    }
    rhino = AKRhinoGuitarProcessor(player)
    AudioKit.output = rhino
    AudioKit.start()
    player.looping = true
    player.start()
} catch let error as NSError {
    print(error.localizedDescription)
}
//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Rhino Guitar Processor")

        addSubview(AKBypassButton(node: rhino))

        addSubview(AKSlider(property: "Pre Gain",
                            value: rhino.preGain,
                            range: 0.0 ... 10.0,
                            format: "%0.2f dB"
        ) { sliderValue in
            rhino.preGain = sliderValue
        })

        addSubview(AKSlider(property: "Dist. Amount",
                            value: rhino.distAmount,
                            range: 1.0 ... 20.0,
                            format: "%0.1f"
        ) { sliderValue in
            rhino.distAmount = sliderValue
        })

        addSubview(AKSlider(property: "Lows",
                            value: rhino.lowGain,
                            range: -1.0 ... 1.0,
                            format: "%0.1f"
        ) { sliderValue in
            rhino.lowGain = sliderValue
        })

        addSubview(AKSlider(property: "Mids",
                            value: rhino.midGain,
                            range: -1.0 ... 1.0,
                            format: "%0.1f"
        ) { sliderValue in
            rhino.midGain = sliderValue
        })

        addSubview(AKSlider(property: "Highs",
                            value: rhino.highGain,
                            range: -1.0 ... 1.0,
                            format: "%0.1f"
        ) { sliderValue in
            rhino.highGain = sliderValue
        })

        addSubview(AKSlider(property: "Output Gain",
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
PlaygroundPage.current.liveView = PlaygroundView()
