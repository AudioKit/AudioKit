//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Peak Limiter
//: ### A peak limiter will set a hard limit on the amplitude of an audio signal. They're espeically useful for any type of live input processing, when you may not be in total control of the audio signal you're recording or processing.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
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

    //: UI Elements we'll need to be able to access
    var attackTimeLabel: Label?
    var decayTimeLabel: Label?
    var preGainLabel: Label?

    override func setup() {
        addTitle("Peak Limiter")

        addLabel("Audio Player")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        addLabel("Peak Limiter Parameters")

        addButton("Process", action: #selector(self.process))
        addButton("Bypass", action: #selector(self.bypass))

        attackTimeLabel = addLabel("Attack Time: \(peakLimiter.attackTime) Secs")
        addSlider(#selector(self.setAttackTime(_:)), value: peakLimiter.attackTime, minimum: 0.001, maximum: 0.03)

        decayTimeLabel = addLabel("Decay Time: \(peakLimiter.decayTime) Secs")
        addSlider(#selector(self.setDecayTime(_:)), value: peakLimiter.decayTime, minimum: 0.001, maximum: 0.06)

        preGainLabel = addLabel("Pre-gain: \(peakLimiter.preGain) dB")
        addSlider(#selector(self.setPreGain(_:)), value: peakLimiter.preGain, minimum: -40, maximum: 40)

    }

    //: Handle UI Events

    func start() {
        player.play()
    }

    func stop() {
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
    }

    func setDecayTime(slider: Slider) {
        peakLimiter.decayTime = Double(slider.value)
        let decayTime = String(format: "%0.3f", peakLimiter.decayTime)
        decayTimeLabel!.text = "decayTime: \(decayTime) Secs"
    }

    func setPreGain(slider: Slider) {
        peakLimiter.preGain = Double(slider.value)
        let preGain = String(format: "%0.3f", peakLimiter.preGain)
        preGainLabel!.text = "preGain: \(preGain) dB"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
