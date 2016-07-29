//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## String Resonator
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var stringResonator = AKStringResonator(player)

//: Set the parameters of the String Resonator here.
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 1000
stringResonator.rampTime = 0.1

AudioKit.output = stringResonator
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("String Resonator")

        addButtons()

        fundamentalFrequencyLabel =
            addLabel("Fundamental Frequency: \(stringResonator.fundamentalFrequency)")
        addSlider(#selector(setFundamentalFrequency),
                  value: stringResonator.fundamentalFrequency,
                  minimum: 0,
                  maximum: 5000)

        feedbackLabel = addLabel("Feedback: \(stringResonator.feedback)")
        addSlider(#selector(setFeedback),
                  value: stringResonator.feedback,
                  minimum: 0,
                  maximum: 0.99)
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

    func setFundamentalFrequency(slider: Slider) {
        stringResonator.fundamentalFrequency = Double(slider.value)
        fundamentalFrequencyLabel!.text = "Fundamental Frequency: " +
            String(format: "%0.0f", stringResonator.fundamentalFrequency)
    }

    func setFeedback(slider: Slider) {
        stringResonator.feedback = Double(slider.value)
        feedbackLabel!.text = "Feedback: \(String(format: "%0.3f", stringResonator.feedback))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 740))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
