//: ## Bit Crush Effect
//: An audio signal consists of two components, amplitude and frequency.
//: When an analog audio signal is converted to a digial representation, these
//: two components are stored by a bit-depth value, and a sample-rate value.
//: The sample-rate represents the number of samples of audio per second, and the
//: bit-depth represents the number of bits used capture that audio. The bit-depth
//: specifies the dynamic range (the difference between the smallest and loudest
//: audio signal). By changing the bit-depth of an audio file, you can create
//: rather interesting digital distortion effects.

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var bitcrusher = AKBitCrusher(player)
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3_333

AudioKit.output = bitcrusher
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Bit Crusher")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Bit Depth",
            format: "%0.2f",
            value: bitcrusher.bitDepth, minimum: 1, maximum: 24,
            color: AKColor.green
        ) { sliderValue in
            bitcrusher.bitDepth = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Sample Rate",
            format: "%0.1f Hz",
            value: bitcrusher.sampleRate, maximum: 16_000,
            color: AKColor.red
        ) { sliderValue in
            bitcrusher.sampleRate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
