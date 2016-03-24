//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Bit Crush Effect
//: ### An audio signal consists of two components, amplitude and frequency. When an analog audio signal is converted to a digial representation, these two components are stored by a bit-depth value, and a sample-rate value. The sample-rate represents the number of samples of audio per second, and the bit-depth represents the number of bits used capture that audio. The bit-depth specifies the dynamic range (the difference between the smallest and loudest audio signal). By changing the bit-depth of an audio file, you can create rather interesting digital distortion effects.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var bitcrusher = AKBitCrusher(player)

//: Set the parameters of the bitcrusher here
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3333

AudioKit.output = bitcrusher
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    var bitDepthLabel: Label?
    var sampleRateLabel: Label?

    override func setup() {
        addTitle("Bit Crusher")

        addLabel("Audio Player")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        bitDepthLabel = addLabel("Bit Depth: \(bitcrusher.bitDepth)")
        addSlider(#selector(self.setBitDepth(_:)), value: bitcrusher.bitDepth, minimum: 1, maximum: 24)

        sampleRateLabel = addLabel("Sample Rate: \(bitcrusher.sampleRate)")
        addSlider(#selector(self.setSampleRate(_:)), value: bitcrusher.sampleRate, minimum: 0, maximum: 16000)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setBitDepth(slider: Slider) {
        bitcrusher.bitDepth = Double(slider.value)
        let bitDepth = String(format: "%0.1f", bitcrusher.bitDepth)
        bitDepthLabel!.text = "Bit Depth: \(bitDepth)"
    }

    func setSampleRate(slider: Slider) {
        bitcrusher.sampleRate = Double(slider.value)
        let sampleRate = String(format: "%0.0f", bitcrusher.sampleRate)
        sampleRateLabel!.text = "Sample Rate: \(sampleRate)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
