//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the
//: ### high-frequency components of the audio signal, allowing for the
//: ### lower frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowPassFilter = AKLowPassFilter(player)

//: Set the parameters here
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?

    override func setup() {
        addTitle("Low Pass Filter")

        addButtons()

        addLabel("Low Pass Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        cutoffFrequencyLabel = addLabel("Cut-off Frequency: \(lowPassFilter.cutoffFrequency) Hz")
        addSlider(#selector(setCutoffFrequency),
                  value: lowPassFilter.cutoffFrequency,
                  minimum: 10,
                  maximum: 22050)

        resonanceLabel = addLabel("Resonance: 0 dB")
        addSlider(#selector(setResonance), value: 0, minimum: -20, maximum: 40)

    }
    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }
    override func stop() {
        player.stop()
    }

    func process() {
        lowPassFilter.start()
    }

    func bypass() {
        lowPassFilter.bypass()
    }

    func setCutoffFrequency(slider: Slider) {
        lowPassFilter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", lowPassFilter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
        printCode()
    }

    func setResonance(slider: Slider) {
        lowPassFilter.resonance = Double(slider.value)
        let resonance = String(format: "%0.1f", lowPassFilter.resonance)
        resonanceLabel!.text = "Resonance: \(resonance) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    cutOffFrequency = " +
            String(format: "%0.3f", lowPassFilter.cutoffFrequency))
        Swift.print("    resonance = \(String(format: "%0.3f", lowPassFilter.resonance))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
