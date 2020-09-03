//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//: ## Playgrounds to Production
//:
//: The intention of most of the AudioKit Playgrounds is to highlight a particular
//: concept.  To keep things clear, we have kept the amount of code to a minimum.
//: But the flipside of that decision is that code from playgrounds will look a little
//: different from production.  In general, to see best practices, you can check out
//: the AudioKit examples project, but here in this playground we'll highlight some
//: important ways playground code differs from production code.
//:
//: In production, you would only import AudioKit, not AudioKitPlaygrounds
import AudioKitPlaygrounds
import AudioKit

//: ### Memory management
//:
//: In a playground, you don't have to worry about whether a node is retained, so you can
//: just write:
let oscillator = AKOscillator()
engine.output = oscillator
try engine.start()

//: But if you did the same type of thing in a project:
class BadAudioEngine {
    init() {
        let oscillator = AKOscillator()
        engine.output = oscillator
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start")
        }
    }
}

//: It wouldn't work because the oscillator node would be lost right after the init
//: method completed.  Instead,  make sure it is declared as an instance variable:
class AudioEngine {
    var oscillator: AKOscillator

    init() {
        oscillator = AKOscillator()
        engine.output = oscillator
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start")
        }
    }
}

//: ### Error Handling
//:
//: In AudioKit playgrounds, failable initializers are just one line:
let file = try AVAudioFile()
try engine.start()

//: In production code, this would need to be wrapped in a do-catch block
do {
    let file = try AVAudioFile(forReading: URL(fileURLWithPath: "drumloop.wav"))
    try engine.start()
} catch {
    print("File Not Found or AudioKit did not start")
}

//: ---
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
