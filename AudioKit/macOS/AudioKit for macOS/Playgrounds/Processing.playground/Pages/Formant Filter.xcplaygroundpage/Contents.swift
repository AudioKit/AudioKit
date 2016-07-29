//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Formant Filter
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKFormantFilter(player)

AudioKit.output = filter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Formant Filter")

        addButtons()

        addLabel("Formant Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        centerFrequencyLabel = addLabel("Center Frequency: \(filter.centerFrequency) Hz")
        addSlider(#selector(setCenterFrequency),
                  value: filter.centerFrequency,
                  minimum: 20,
                  maximum: 22050)

        attackLabel = addLabel("Attack: \(filter.attackDuration) Seconds")
        addSlider(#selector(setAttack), value: filter.attackDuration, minimum: 0, maximum: 0.1)

        decayLabel = addLabel("Decay: \(filter.decayDuration) Seconds")
        addSlider(#selector(setDecay), value: filter.decayDuration, minimum: 0, maximum: 0.1)

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
        filter.play()
    }

    func bypass() {
        filter.bypass()
    }

    func setCenterFrequency(slider: Slider) {
        filter.centerFrequency = Double(slider.value)
        let frequency = String(format: "%0.1f", filter.centerFrequency)
        centerFrequencyLabel!.text = "Center Frequency: \(frequency) Hz"
        printCode()
    }

    func setAttack(slider: Slider) {
        filter.attackDuration = Double(slider.value)
        let attack = String(format: "%0.3f", filter.attackDuration)
        attackLabel!.text = "Attack: \(attack) Seconds"
        printCode()
    }

    func setDecay(slider: Slider) {
        filter.decayDuration = Double(slider.value)
        let decay = String(format: "%0.3f", filter.decayDuration)
        decayLabel!.text = "Decay: \(decay) Seconds"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    centerFrequency = \(String(format: "%0.3f", filter.centerFrequency))")
        Swift.print("    attackDuration = \(String(format: "%0.3f", filter.attackDuration))")
        Swift.print("    decayDuration = \(String(format: "%0.3f", filter.decayDuration))")
        Swift.print("}\n")
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 750))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
