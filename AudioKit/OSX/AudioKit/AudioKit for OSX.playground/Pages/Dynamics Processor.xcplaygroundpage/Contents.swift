//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dynamics Processor
//: ### The AKDynamicsProcessor is both a compressor and an expander based on apple's Dynamics Processor audio unit. threshold and headRoom (similar to 'ratio' you might be more familiar with) are specific to the compressor, expansionRatio and expansionThreshold control the expander.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var dynamicsProcessor = AKDynamicsProcessor(player)

//: Set the parameters here
dynamicsProcessor.threshold
dynamicsProcessor.headRoom
dynamicsProcessor.expansionRatio
dynamicsProcessor.expansionThreshold
dynamicsProcessor.attackTime
dynamicsProcessor.releaseTime
dynamicsProcessor.masterGain

AudioKit.output = dynamicsProcessor
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var thresholdLabel: Label?
    var headRoomLabel: Label?
    var expansionRatioLabel: Label?
    var expansionThresholdLabel: Label?
    var attackTimeLabel: Label?
    var releaseTimeLabel: Label?
    var masterGainLabel: Label?

    override func setup() {
        addTitle("Dynamics Processor")

        addLabel("Audio Player")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        addLabel("Dynamics Processor Parameters")

        addButton("Process", action: #selector(self.process))
        addButton("Bypass", action: #selector(self.bypass))

        thresholdLabel = addLabel("Threshold: \(dynamicsProcessor.threshold) dB")
        addSlider(#selector(self.setThreshold(_:)), value: dynamicsProcessor.threshold, minimum: -40, maximum: 20)

        headRoomLabel = addLabel("Head Room: \(dynamicsProcessor.headRoom) dB")
        addSlider(#selector(self.setHeadRoom(_:)), value: dynamicsProcessor.headRoom, minimum: 0.1, maximum: 40.0)

        expansionRatioLabel = addLabel("Expansion Ratio: \(dynamicsProcessor.expansionRatio) rate")
        addSlider(#selector(self.setExpansionRatio(_:)), value: dynamicsProcessor.expansionRatio, minimum: 1, maximum: 50.0)

        expansionThresholdLabel = addLabel("Expansion Threshold: \(dynamicsProcessor.expansionThreshold) rate")
        addSlider(#selector(self.setExpansionThreshold(_:)), value: dynamicsProcessor.expansionThreshold, minimum: 1, maximum: 50.0)

        attackTimeLabel = addLabel("Attack Time: \(dynamicsProcessor.attackTime) secs")
        addSlider(#selector(self.setAttackTime(_:)), value: dynamicsProcessor.attackTime, minimum: 0.0001, maximum: 0.2)

        releaseTimeLabel = addLabel("Release Time: \(dynamicsProcessor.releaseTime) secs")
        addSlider(#selector(self.setReleaseTime(_:)), value: dynamicsProcessor.releaseTime, minimum: 0.01, maximum: 3)

        masterGainLabel = addLabel("Master Gain: \(dynamicsProcessor.masterGain) dB")
        addSlider(#selector(self.setMasterGain(_:)), value: dynamicsProcessor.masterGain, minimum: -40, maximum: 40)
    }

    //: Handle UI Events

    func start() {
        player.play()
    }

    func stop() {
        player.stop()
    }

    func process() {
        dynamicsProcessor.start()
    }

    func bypass() {
        dynamicsProcessor.bypass()
    }
    func setThreshold(slider: Slider) {
        dynamicsProcessor.threshold = Double(slider.value)
        let threshold = String(format: "%0.3f", dynamicsProcessor.threshold)
        thresholdLabel!.text = "Threshold: \(threshold) dB"
    }

    func setHeadRoom(slider: Slider) {
        dynamicsProcessor.headRoom = Double(slider.value)
        let headRoom = String(format: "%0.3f", dynamicsProcessor.headRoom)
        headRoomLabel!.text = "Head Room: \(headRoom) dB"
    }

    func setExpansionRatio(slider: Slider) {
        dynamicsProcessor.expansionRatio = Double(slider.value)
        let expansionRatio = String(format: "%0.3f", dynamicsProcessor.expansionRatio)
        expansionRatioLabel!.text = "Expansion Ratio: \(expansionRatio) rate"
    }

    func setExpansionThreshold(slider: Slider) {
        dynamicsProcessor.expansionThreshold = Double(slider.value)
        let expansionThreshold = String(format: "%0.3f", dynamicsProcessor.expansionThreshold)
        expansionThresholdLabel!.text = "Expansion Threshold: \(expansionThreshold) rate"
    }

    func setAttackTime(slider: Slider) {
        dynamicsProcessor.attackTime = Double(slider.value)
        let attackTime = String(format: "%0.3f", dynamicsProcessor.attackTime)
        attackTimeLabel!.text = "Attack Time: \(attackTime) secs"
    }

    func setReleaseTime(slider: Slider) {
        dynamicsProcessor.releaseTime = Double(slider.value)
        let releaseTime = String(format: "%0.3f", dynamicsProcessor.releaseTime)
        releaseTimeLabel!.text = "Release Time: \(releaseTime) secs"
    }

    func setMasterGain(slider: Slider) {
        dynamicsProcessor.masterGain = Double(slider.value)
        let masterGain = String(format: "%0.3f", dynamicsProcessor.masterGain)
        masterGainLabel!.text = "Master Gain: \(masterGain) dB"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
