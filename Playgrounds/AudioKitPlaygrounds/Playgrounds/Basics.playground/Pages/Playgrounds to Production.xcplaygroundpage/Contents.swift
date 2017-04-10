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
AudioKit.output = oscillator
AudioKit.start()

//: But if you did the same type of thing in a project:
class BadAudioEngine {
    init() {
        let oscillator = AKOscillator()
        AudioKit.output = oscillator
        AudioKit.start()
    }
}

//: It wouldn't work because the oscillator node would be lost right after the init
//: method completed.  Instead,  makensure it is declared as an instance variable:
class AudioEngine {
    var oscillator: AKOscillator
    
    init() {
        oscillator = AKOscillator()
        AudioKit.output = oscillator
        AudioKit.start()
    }
}

//: ### Error Handling
//:
//: In AudioKit playgrounds, failable initializers are just one line:
let file = try AKAudioFile()
var player = try AKAudioPlayer(file: file)

//: In production code, this would need to be wrapped in a do-catch block
do {
    let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)
    player = try AKAudioPlayer(file: file)
} catch {
    AKLog("File Not Found")
}

//: ---
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
