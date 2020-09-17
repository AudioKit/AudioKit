//: ## Rhino Guitar Processor


import AudioKit

var rhino: RhinoGuitarProcessor!

do {
    let guitarFile = try AVAudioFile(readFileName: "guitar.wav")

    let player = try AudioPlayer(file: guitarFile)
    player.looping = true
    rhino = RhinoGuitarProcessor(player)
    let reverb = Reverb(rhino)
    engine.output = Mixer(reverb, rhino)
    try engine.start()
    player.play()
} catch let error as NSError {
    Log(error.localizedDescription)
}
//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Rhino Guitar Processor")

        addView(Button(title: "Stop Rhino") { button in
            rhino.isStarted ? rhino.stop() : rhino.play()
            button.title = rhino.isStarted ? "Stop Rhino" : "Start Rhino"
        })

        addView(Slider(property: "Pre Gain",
                         value: rhino.preGain,
                         range: 0.0 ... 10.0,
                         format: "%0.2f"
        ) { sliderValue in
            rhino.preGain = sliderValue
        })

        addView(Slider(property: "Dist. Amount",
                         value: rhino.distortion,
                         range: 1.0 ... 20.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.distortion = sliderValue
        })

        addView(Slider(property: "Lows",
                         value: rhino.lowGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.lowGain = sliderValue
        })

        addView(Slider(property: "Mids",
                         value: rhino.midGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.midGain = sliderValue
        })

        addView(Slider(property: "Highs",
                         value: rhino.highGain,
                         range: -1.0 ... 1.0,
                         format: "%0.1f"
        ) { sliderValue in
            rhino.highGain = sliderValue
        })

        addView(Slider(property: "Output Gain",
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
