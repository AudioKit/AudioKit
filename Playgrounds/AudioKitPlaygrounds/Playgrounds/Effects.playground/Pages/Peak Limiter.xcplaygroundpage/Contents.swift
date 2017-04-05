//: ## Peak Limiter
//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: They're espeically useful for any type of live input processing, when you
//: may not be in total control of the audio signal you're recording or processing.

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

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

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Peak Limiter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: peakLimiter))

        addSubview(AKPropertySlider(
            property: "Attack Time",
            format:  "%0.3f s",
            value: peakLimiter.attackTime, minimum: 0.001, maximum: 0.03,
            color: AKColor.green
        ) { sliderValue in
            peakLimiter.attackTime = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Decay Time",
            format:  "%0.3f s",
            value: peakLimiter.decayTime, minimum: 0.001, maximum: 0.03,
            color: AKColor.green
        ) { sliderValue in
            peakLimiter.decayTime = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Pre-gain",
            format:  "%0.1f dB",
            value: peakLimiter.preGain, minimum: -40, maximum: 40,
            color: AKColor.green
        ) { sliderValue in
            peakLimiter.preGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
