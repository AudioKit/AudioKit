//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let sawtooth = AKTable(.Sawtooth, size: 16)
for value in sawtooth.values { value } // Click the eye icon ->
var oscBase = AKOscillator(table: sawtooth)
var oscillatorPoly = AKMidiInstrument(osc: oscBase, numVoicesInit: 4)
audiokit.audioOutput = oscillatorPoly

audiokit.start()

var inc = 0

let major = [0, 4, 7]

//: This is a loop to send a random note to the sampler
//: The sampler 'playNote' function is very useful here
//AKPlaygroundLoop(every: 2) {
//    let scale = [0,2,4,5,7,9,11,12]
//    var note = scale.randomElement()
//    let octave = randomInt(3...7)  * 12
//    if random(0, 10) < 1.0 { note++ }
//    if !scale.contains(note % 12) { print("ACCIDENT!") }
//    for i in 0...2 {
//        oscillator.internalMIDIInstrument.startNote(UInt8(note + octave + major[i]), withVelocity: 64, onChannel: 0)
//    }
//    print("")
//}

//AKPlaygroundLoop(frequency: 1) {
    AKPlaygroundLoop(frequency: 5) {
        let note = UInt8(randomInt(40...100))
        oscillatorPoly.startNote(note, withVelocity: UInt8(randomInt(10...30)), onChannel: 0)
    }
//}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
