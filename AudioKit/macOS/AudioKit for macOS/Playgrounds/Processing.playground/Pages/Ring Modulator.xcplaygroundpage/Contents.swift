//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulator
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var ringModulator = AKRingModulator(player)

//: Set the parameters here
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

AudioKit.output = ringModulator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var ringModFreq1Label: Label?
    var ringModFreq2Label: Label?
    var ringModBalanceLabel: Label?
    var finalMixLabel: Label?

    override func setup() {
        addTitle("Ring Modulator")

        addButtons()

        addLabel("Ring Modulator Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        ringModFreq1Label = addLabel("Frequency 1: \(ringModulator.frequency1) Hertz")
        addSlider(#selector(setFreq1), value: ringModulator.frequency1, minimum: 0.5, maximum: 8000)

        ringModFreq2Label = addLabel("Frequency 2: \(ringModulator.frequency2) Hertz")
        addSlider(#selector(setFreq2), value: ringModulator.frequency2, minimum: 0.5, maximum: 8000)

        ringModBalanceLabel = addLabel("Balance: \(ringModulator.balance)")
        addSlider(#selector(setBalance), value: ringModulator.balance)

        finalMixLabel = addLabel("Finalmix: \(ringModulator.mix)")
        addSlider(#selector(setMix), value: ringModulator.mix)

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
        ringModulator.start()
    }

    func bypass() {
        ringModulator.bypass()
    }

    func setFreq1(slider: Slider) {
        ringModulator.frequency1 = Double(slider.value)
        let ringModFreq1 = String(format: "%0.1f", ringModulator.frequency1)
        ringModFreq1Label!.text = "Frequency 1: \(ringModFreq1) Hertz"
        printCode()
    }

    func setFreq2(slider: Slider) {
        ringModulator.frequency2 = Double(slider.value)
        let ringModFreq2 = String(format: "%0.1f", ringModulator.frequency2)
        ringModFreq2Label!.text = "Frequency 2: \(ringModFreq2) Hertz"
        printCode()
    }

    func setBalance(slider: Slider) {
        ringModulator.balance = Double(slider.value)
        let ringModBalance = String(format: "%0.1f", ringModulator.balance)
        ringModBalanceLabel!.text = "Balance: \(ringModBalance)"
        printCode()
    }

    func setMix(slider: Slider) {
        ringModulator.mix = Double(slider.value)
        let finalMix = String(format: "%0.1f", ringModulator.mix)
        finalMixLabel!.text = "Mix: \(finalMix)"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    frequency1 = \(String(format: "%0.3f", ringModulator.frequency1))")
        Swift.print("    frequency2 = \(String(format: "%0.3f", ringModulator.frequency2))")
        Swift.print("    balance = \(String(format: "%0.3f", ringModulator.balance))")
        Swift.print("    mix = \(String(format: "%0.3f", ringModulator.mix))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
