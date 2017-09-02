//: ## Peak Limiter
//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: They're espeically useful for any type of live input processing, when you
//: may not be in total control of the audio signal you're recording or processing.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var peakLimiter = AKPeakLimiter(player)
peakLimiter.attackTime = 0.001 // Secs
peakLimiter.decayTime = 0.01 // Secs
peakLimiter.preGain = 10 // dB

AudioKit.output = peakLimiter
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Peak Limiter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: peakLimiter))

        addSubview(AKSlider(property: "Attack Time",
                            value: peakLimiter.attackTime,
                            range: 0.001 ... 0.03,
                            format:  "%0.3f s"
        ) { sliderValue in
            peakLimiter.attackTime = sliderValue
        })

        addSubview(AKSlider(property: "Decay Time",
                            value: peakLimiter.decayTime,
                            range: 0.001 ... 0.03,
                            format:  "%0.3f s"
        ) { sliderValue in
            peakLimiter.decayTime = sliderValue
        })

        addSubview(AKSlider(property: "Pre-gain",
                            value: peakLimiter.preGain,
                            range: -40 ... 40,
                            format:  "%0.1f dB"
        ) { sliderValue in
            peakLimiter.preGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
