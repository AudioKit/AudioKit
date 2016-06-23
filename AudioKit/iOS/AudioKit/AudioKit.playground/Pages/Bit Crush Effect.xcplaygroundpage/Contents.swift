//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Bit Crush Effect
//: ### An audio signal consists of two components, amplitude and frequency. When an analog audio signal is converted to a digial representation, these two components are stored by a bit-depth value, and a sample-rate value. The sample-rate represents the number of samples of audio per second, and the bit-depth represents the number of bits used capture that audio. The bit-depth specifies the dynamic range (the difference between the smallest and loudest audio signal). By changing the bit-depth of an audio file, you can create rather interesting digital distortion effects.
import XCPlayground
import AudioKit

let file = try? AKAudioFile(forReadingWithFileName: "drumloop.wav", fromBaseDirectory: .resources)

let player = try? AKAudioPlayer(file: file!)
player!.looping = true
var bitcrusher = AKBitCrusher(player!)

//: Set the parameters of the bitcrusher here
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3333

AudioKit.output = bitcrusher
AudioKit.start()

player!.play()

class PlaygroundView: AKPlaygroundView {

    var bitDepthLabel: Label?
    var sampleRateLabel: Label?

    override func setup() {
        addTitle("Bit Crusher")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        bitDepthLabel = addLabel("Bit Depth: \(bitcrusher.bitDepth)")
        addSlider(#selector(setBitDepth), value: bitcrusher.bitDepth, minimum: 1, maximum: 24)

        sampleRateLabel = addLabel("Sample Rate: \(bitcrusher.sampleRate)")
        addSlider(#selector(setSampleRate), value: bitcrusher.sampleRate, minimum: 0, maximum: 16000)
    }

    func startLoop(part: String) {
        player!.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav", fromBaseDirectory: .resources)
        try? player!.replaceFile(file!)
        player!.play()
    }

    func startDrumLoop() {
        startLoop("drum")
    }

    func startBassLoop() {
        startLoop("bass")
    }

    func startGuitarLoop() {
        startLoop("guitar")
    }

    func startLeadLoop() {
        startLoop("lead")
    }

    func startMixLoop() {
        startLoop("mix")
    }
    func stop() {
        player!.stop()
    }

    func setBitDepth(slider: Slider) {
        bitcrusher.bitDepth = Double(slider.value)
        let bitDepth = String(format: "%0.1f", bitcrusher.bitDepth)
        bitDepthLabel!.text = "Bit Depth: \(bitDepth)"
        printCode()
    }

    func setSampleRate(slider: Slider) {
        bitcrusher.sampleRate = Double(slider.value)
        let sampleRate = String(format: "%0.0f", bitcrusher.sampleRate)
        sampleRateLabel!.text = "Sample Rate: \(sampleRate)"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        print("public func presetXXXXXX() {")
        print("    bitDepth = \(String(format: "%0.3f", bitcrusher.bitDepth))")
        print("    sampleRate = \(String(format: "%0.3f", bitcrusher.sampleRate))")

        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next]
