//: ## Bit Crush Effect
//: An audio signal consists of two components, amplitude and frequency.
//: When an analog audio signal is converted to a digial representation, these
//: two components are stored by a bit-depth value, and a sample-rate value.
//: The sample-rate represents the number of samples of audio per second, and the
//: bit-depth represents the number of bits used capture that audio. The bit-depth
//: specifies the dynamic range (the difference between the smallest and loudest
//: audio signal). By changing the bit-depth of an audio file, you can create
//: rather interesting digital distortion effects.
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var bitcrusher = AKBitCrusher(player)
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3_333

AudioKit.output = bitcrusher
AudioKit.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Bit Crusher")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Bit Depth",
                         value: bitcrusher.bitDepth,
                         range: 1 ... 24
        ) { sliderValue in
            bitcrusher.bitDepth = sliderValue
        })

        addView(AKSlider(property: "Sample Rate",
                         value: bitcrusher.sampleRate,
                         range: 1 ... 16_000,
                         format: "%0.1f Hz"
        ) { sliderValue in
            bitcrusher.sampleRate = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
