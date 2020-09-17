//: ## Tone and Tone Complement Filters
//: ##

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var toneFilter = ToneFilter(player)
var toneComplement = ToneComplementFilter(toneFilter)

engine.output = toneComplement
try engine.start()

player.play()


class LiveView: View {

    override func viewDidLoad() {
        addTitle("Tone Filters")

        addView(Button(title: "Stop Tone Filter") { button in
            toneFilter.isStarted ? toneFilter.stop() : toneFilter.play()
            button.title = toneFilter.isStarted ? "Stop Tone Filter" : "Start Tone Filter"
        })

        addView(Slider(property: "Half Power Point",
                         value: toneFilter.halfPowerPoint,
                         range: 0 ... 10_000,
                         taper: 5
        ) { sliderValue in
            toneFilter.halfPowerPoint = sliderValue
        })

        addView(Button(title: "Stop Tone Complement") { button in
            toneComplement.isStarted ? toneComplement.stop() : toneComplement.play()
            button.title = toneComplement.isStarted ? "Stop Tone Complement" : "Start Tone Complement"
        })

        addView(Slider(property: "Half Power Point",
                         value: toneComplement.halfPowerPoint,
                         range: 0 ... 10_000,
                         taper: 5
        ) { sliderValue in
            toneComplement.halfPowerPoint = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
