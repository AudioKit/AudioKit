//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Distortion
//: ### This thing is a beast.
//:
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var distortion = AKDistortion(player)

//: Set the parameters here
distortion.delay  = 0.1
distortion.decay  = 1.0
distortion.delayMix  = 0.5
distortion.linearTerm  = 0.5
distortion.squaredTerm  = 0.5
distortion.cubicTerm  = 50
distortion.polynomialMix  = 0.5
distortion.softClipGain  = -6
distortion.finalMix  = 0.5

AudioKit.output = distortion
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var delayLabel: Label?
    var decayLabel: Label?
    var delayMixLabel: Label?
    var linearTermLabel: Label?
    var squaredTermLabel: Label?
    var cubicTermLabel: Label?
    var polynomialMixLabel: Label?
    var softClipGainLabel: Label?
    var finalMixLabel: Label?

    override func setup() {
        addTitle("Distortion")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("Distortion Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        delayLabel = addLabel("Delay: \(distortion.delay) Milliseconds")
        addSlider(#selector(setDelay), value: distortion.delay, minimum: 0.1, maximum: 500)

        decayLabel = addLabel("Decay: \(distortion.decay) Rate")
        addSlider(#selector(setDecay), value: distortion.decay, minimum: 0.1, maximum: 50)

        delayMixLabel = addLabel("Delay Mix: \(distortion.delayMix)")
        addSlider(#selector(setDelayMix), value: distortion.delayMix)

        linearTermLabel = addLabel("Linear Term: \(distortion.linearTerm)")
        addSlider(#selector(setLinearTerm), value: distortion.linearTerm)

        squaredTermLabel = addLabel("Squared Term: \(distortion.squaredTerm)")
        addSlider(#selector(setSquaredTerm), value: distortion.squaredTerm)

        cubicTermLabel = addLabel("Cubic Term: \(distortion.cubicTerm)")
        addSlider(#selector(setCubicTerm), value: distortion.cubicTerm)

        polynomialMixLabel = addLabel("Polynomial Mix: \(distortion.polynomialMix)")
        addSlider(#selector(setPolynomialMix), value: distortion.polynomialMix)

        softClipGainLabel = addLabel("Soft Clip Gain: \(distortion.softClipGain) dB")
        addSlider(#selector(setSoftClipGain), value: distortion.softClipGain, minimum: -80, maximum: 20)

        finalMixLabel = addLabel("Final Mix: \(distortion.finalMix)")
        addSlider(#selector(setFinalMix), value: distortion.finalMix)

    }

    //: Handle UI Events

    func startLoop(_ part: String) {
        player.stop()
        let file = bundle.pathForResource("\(part)loop", ofType: "wav")
        player.replaceFile(file!)
        player.play()
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
        player.stop()
    }

    func process() {
        distortion.start()
    }

    func bypass() {
        distortion.bypass()
    }
    func setDelay(slider: Slider) {
        distortion.delay = Double(slider.value)
        let delay = String(format: "%0.3f", distortion.delay)
        delayLabel!.text = "Delay: \(delay) Milliseconds"
    }

    func setDecay(slider: Slider) {
        distortion.decay = Double(slider.value)
        let decay = String(format: "%0.3f", distortion.decay)
        decayLabel!.text = "Decay: \(decay) Rate"
    }

    func setDelayMix(slider: Slider) {
        distortion.delayMix = Double(slider.value)
        let delayMix = String(format: "%0.3f", distortion.delayMix)
        delayMixLabel!.text = "Delay Mix: \(delayMix)"
    }

    func setLinearTerm(slider: Slider) {
        distortion.linearTerm = Double(slider.value)
        let linearTerm = String(format: "%0.3f", distortion.linearTerm)
        linearTermLabel!.text = "linearTerm: \(linearTerm)"
    }

    func setSquaredTerm(slider: Slider) {
        distortion.squaredTerm = Double(slider.value)
        let squaredTerm = String(format: "%0.3f", distortion.squaredTerm)
        squaredTermLabel!.text = "squaredTerm: \(squaredTerm)"
    }

    func setCubicTerm(slider: Slider) {
        distortion.cubicTerm = Double(slider.value)
        let cubicTerm = String(format: "%0.3f", distortion.cubicTerm)
        cubicTermLabel!.text = "cubicTerm: \(cubicTerm)"
    }

    func setPolynomialMix(slider: Slider) {
        distortion.polynomialMix = Double(slider.value)
        let polynomialMix = String(format: "%0.3f", distortion.polynomialMix)
        polynomialMixLabel!.text = "polynomialMix: \(polynomialMix)"
    }

    func setSoftClipGain(slider: Slider) {
        distortion.softClipGain = Double(slider.value)
        let softClipGain = String(format: "%0.3f", distortion.softClipGain)
        softClipGainLabel!.text = "softClipGain: \(softClipGain) dB"
    }

    func setFinalMix(slider: Slider) {
        distortion.finalMix = Double(slider.value)
        let finalMix = String(format: "%0.3f", distortion.finalMix)
        finalMixLabel!.text = "finalMix: \(finalMix)"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
