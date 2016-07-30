//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Delay
//: ### Exploring the powerful effect of repeating sounds after
//: ### varying length delay times and feedback amounts
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    var timeSlider: AKPropertySlider?
    var feedbackSlider: AKPropertySlider?
    var lowPassCutoffFrequencySlider: AKPropertySlider?
    var dryWetMixSlider: AKPropertySlider?

    override func setup() {
        addTitle("Delay")

        addButtons()
        addButton("Short", action: #selector(presetShortDelay))
        addButton("Dense Long", action: #selector(presetDenseLongDelay))
        addButton("Electric Circuits", action: #selector(presetElectricCircuitsDelay))

        timeSlider = AKPropertySlider(
            property: "Time",
            value: delay.time,
            color: AKColor.greenColor()
        ) { sliderValue in
            delay.time = sliderValue
            }
        addSubview(timeSlider!)
        
        feedbackSlider = AKPropertySlider(
            property: "Feedback",
            value: delay.feedback,
            color: AKColor.redColor()
        ) { sliderValue in
            delay.feedback = sliderValue
        }
        addSubview(feedbackSlider!)
        
        lowPassCutoffFrequencySlider = AKPropertySlider(
            property: "Low Pass Cutoff",
            value: delay.lowPassCutoff, maximum: 22050,
            color: AKColor.magentaColor()
        ) { sliderValue in
            delay.lowPassCutoff = sliderValue
        }
        addSubview(lowPassCutoffFrequencySlider!)
        
        dryWetMixSlider = AKPropertySlider(
            property: "Mix",
            value: delay.dryWetMix,
            color: AKColor.cyanColor()
        ) { sliderValue in
            delay.dryWetMix = sliderValue
        }
        addSubview(dryWetMixSlider!)
        
        dryWetMixSlider = AKPropertySlider(
            property: "Mix",
            value: delay.dryWetMix,
            color: AKColor.cyanColor()
        ) { sliderValue in
            delay.dryWetMix = sliderValue
        }
        addSubview(dryWetMixSlider!)
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

    func presetShortDelay() {
        delay.presetShortDelay()
        delay.start()
        updateUI()
    }

    func presetDenseLongDelay() {
        delay.presetDenseLongDelay()
        delay.start()
        updateUI()
    }

    func presetElectricCircuitsDelay() {
        delay.presetElectricCircuitsDelay()
        delay.start()
        updateUI()
    }

    func printCode() {

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    time = \(String(format: "%0.3f", delay.time))")
        Swift.print("    feedback = \(String(format: "%0.3f", delay.feedback))")
        Swift.print("    lowPassCutoff = \(String(format: "%0.3f", delay.lowPassCutoff))")
        Swift.print("    dryWetMix = \(String(format: "%0.3f", delay.dryWetMix))")
        Swift.print("}\n")
    }

    func updateUI() {
        timeSlider?.value = delay.time
        feedbackSlider?.value = delay.feedback
        lowPassCutoffFrequencySlider?.value = delay.lowPassCutoff
        dryWetMixSlider?.value = delay.dryWetMix
        printCode()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
