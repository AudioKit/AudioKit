//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Metronome
//:
import AudioKit
import XCPlayground

var currentFrequency = 60.0

let generator = AKOperationGenerator() { parameters in
    let beep = AKOperation.sineWave(frequency: 480)
    
    let trig = AKOperation.metronome(frequency: parameters[0] / 60)
    
    let beeps = beep.triggeredWithEnvelope(
        trigger: trig,
        attack: 0.01, hold: 0, release: 0.05)
    return beeps
}

generator.parameters = [currentFrequency]

AudioKit.output = generator
AudioKit.start()
generator.start()


class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Metronome")
        
        self.addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f BPM",
            value: 60, minimum: 40, maximum: 240,
            color: AKColor.greenColor(),
            frame: CGRect(x: 30, y: 30, width: self.bounds.width - 60, height: 55)
        ) { frequency in
            generator.parameters[0] = frequency
        })
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 160))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
