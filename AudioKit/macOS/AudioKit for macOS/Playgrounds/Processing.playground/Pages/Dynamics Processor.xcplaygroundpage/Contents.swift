//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dynamics Processor
//: ### The AKDynamicsProcessoris both a compressor and an expander based on
//: ### Apple's Dynamics Processor audio unit. threshold and headRoom (similar to
//: ### 'ratio' you might be more familiar with) are specific to the compressor,
//: ### expansionRatio and expansionThreshold control the expander.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var effect = AKDynamicsProcessor(player)

//: Set the parameters here
effect.threshold
effect.headRoom
effect.expansionRatio
effect.expansionThreshold
effect.attackTime
effect.releaseTime
effect.masterGain

AudioKit.output = effect
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

        addButtons()

        addLabel("Dynamics Processor Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        thresholdLabel = addLabel("Threshold: \(effect.threshold) dB")
        setupSliders()
    }

    func setupSliders() {
        addSlider(#selector(setThreshold),
                  value: effect.threshold,
                  minimum: -40,
                  maximum: 20)

        headRoomLabel = addLabel("Head Room: \(effect.headRoom) dB")
        addSlider(#selector(setHeadRoom),
                  value: effect.headRoom,
                  minimum: 0.1,
                  maximum: 40.0)

        expansionRatioLabel = addLabel("Expansion Ratio: \(effect.expansionRatio) rate")
        addSlider(#selector(setExpansionRatio),
                  value: effect.expansionRatio,
                  minimum: 1,
                  maximum: 50.0)

        expansionThresholdLabel = addLabel("Expansion Threshold: \(effect.expansionThreshold) rate")
        addSlider(#selector(setExpansionThreshold),
                  value: effect.expansionThreshold,
                  minimum: 1,
                  maximum: 50.0)

        attackTimeLabel = addLabel("Attack Time: \(effect.attackTime) secs")
        addSlider(#selector(setAttackTime),
                  value: effect.attackTime,
                  minimum: 0.0001,
                  maximum: 0.2)

        releaseTimeLabel = addLabel("Release Time: \(effect.releaseTime) secs")
        addSlider(#selector(setReleaseTime),
                  value: effect.releaseTime,
                  minimum: 0.01,
                  maximum: 3)

        masterGainLabel = addLabel("Master Gain: \(effect.masterGain) dB")
        addSlider(#selector(setMasterGain),
                  value: effect.masterGain,
                  minimum: -40,
                  maximum: 40)
    }

    //: Handle UI Events

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
        effect.start()
    }

    func bypass() {
        effect.bypass()
    }

    func setThreshold(slider: Slider) {
        effect.threshold = Double(slider.value)
        let threshold = String(format: "%0.3f", effect.threshold)
        thresholdLabel!.text = "Threshold: \(threshold) dB"
        printCode()
    }

    func setHeadRoom(slider: Slider) {
        effect.headRoom = Double(slider.value)
        let headRoom = String(format: "%0.3f", effect.headRoom)
        headRoomLabel!.text = "Head Room: \(headRoom) dB"
        printCode()
    }

    func setExpansionRatio(slider: Slider) {
        effect.expansionRatio = Double(slider.value)
        let expansionRatio = String(format: "%0.3f", effect.expansionRatio)
        expansionRatioLabel!.text = "Expansion Ratio: \(expansionRatio) rate"
        printCode()
    }

    func setExpansionThreshold(slider: Slider) {
        effect.expansionThreshold = Double(slider.value)
        let expansionThreshold = String(format: "%0.3f", effect.expansionThreshold)
        expansionThresholdLabel!.text = "Expansion Threshold: \(expansionThreshold) rate"
        printCode()
    }

    func setAttackTime(slider: Slider) {
        effect.attackTime = Double(slider.value)
        let attackTime = String(format: "%0.3f", effect.attackTime)
        attackTimeLabel!.text = "Attack Time: \(attackTime) secs"
        printCode()
    }

    func setReleaseTime(slider: Slider) {
        effect.releaseTime = Double(slider.value)
        let releaseTime = String(format: "%0.3f", effect.releaseTime)
        releaseTimeLabel!.text = "Release Time: \(releaseTime) secs"
        printCode()
    }

    func setMasterGain(slider: Slider) {
        effect.masterGain = Double(slider.value)
        let masterGain = String(format: "%0.3f", effect.masterGain)
        masterGainLabel!.text = "Master Gain: \(masterGain) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    threshold = \(String(format: "%0.3f", effect.threshold))")
        Swift.print("    headRoom = \(String(format: "%0.3f", effect.headRoom))")
        Swift.print("    expansionRatio = \(String(format: "%0.3f", effect.expansionRatio))")
        Swift.print("    attackTime = \(String(format: "%0.3f", effect.attackTime))")
        Swift.print("    releaseTime = \(String(format: "%0.3f", effect.releaseTime))")
        Swift.print("    masterGain = \(String(format: "%0.3f", effect.masterGain))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
