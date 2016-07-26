//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Peak Limiter
//: ### A peak limiter will set a hard limit on the amplitude of an audio signal.
//: ### They're espeically useful for any type of live input processing, when you
//: ### may not be in total control of the audio signal you're recording or processing.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var peakLimiter = AKPeakLimiter(player)

//: Set the parameters here
peakLimiter.attackTime = 0.001 // Secs
peakLimiter.decayTime = 0.01 // Secs
peakLimiter.preGain = 10 // dB

AudioKit.output = peakLimiter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var attackTimeLabel: Label?
    var decayTimeLabel: Label?
    var preGainLabel: Label?

    override func setup() {
        addTitle("Peak Limiter")

        addButtons()

        addLabel("Peak Limiter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        attackTimeLabel = addLabel("Attack Time: \(peakLimiter.attackTime) Secs")
        addSlider(#selector(setAttackTime),
                  value: peakLimiter.attackTime,
                  minimum: 0.001,
                  maximum: 0.03)

        decayTimeLabel = addLabel("Decay Time: \(peakLimiter.decayTime) Secs")
        addSlider(#selector(setDecayTime),
                  value: peakLimiter.decayTime,
                  minimum: 0.001,
                  maximum: 0.06)

        preGainLabel = addLabel("Pre-gain: \(peakLimiter.preGain) dB")
        addSlider(#selector(setPreGain),
                  value: peakLimiter.preGain,
                  minimum: -40,
                  maximum: 40)

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
        peakLimiter.start()
    }

    func bypass() {
        peakLimiter.bypass()
    }

    func setAttackTime(slider: Slider) {
        peakLimiter.attackTime = Double(slider.value)
        let attackTime = String(format: "%0.3f", peakLimiter.attackTime)
        attackTimeLabel!.text = "attackTime: \(attackTime) Secs"
        printCode()
    }

    func setDecayTime(slider: Slider) {
        peakLimiter.decayTime = Double(slider.value)
        let decayTime = String(format: "%0.3f", peakLimiter.decayTime)
        decayTimeLabel!.text = "decayTime: \(decayTime) Secs"
        printCode()
    }

    func setPreGain(slider: Slider) {
        peakLimiter.preGain = Double(slider.value)
        let preGain = String(format: "%0.3f", peakLimiter.preGain)
        preGainLabel!.text = "preGain: \(preGain) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    attackTime = \(String(format: "%0.3f", peakLimiter.attackTime))")
        Swift.print("    decayTime = \(String(format: "%0.3f", peakLimiter.decayTime))")
        Swift.print("    preGain = \(String(format: "%0.3f", peakLimiter.preGain))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
