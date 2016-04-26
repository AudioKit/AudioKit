//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sampler Instrument - EXS24
//: ### Loading a sampler with an EXS24 instrument

import XCPlayground
import AudioKit

let pulse = 0.5 // seconds

//: We are going to load an EXS24 instrument and send it random notes

let sampler = AKSampler()

//: Here is where we reference the EXS24 file as it is in the app bundle
sampler.loadEXS24("Sounds/sawPiano1")

//: NOTE: As of Xcode 7.3, the EXS24 sampler has stopped working properly in playgrounds. We have filed a bug report and we hope that Apple fixes it in the future.  With that hope, we haven't deleted this playground.  The EXS24 works just fine in a project setting, just not in playgrounds.  To see how it used to work visit: https://vimeo.com/152230901

var delay  = AKDelay(sampler)
delay.time = pulse * 1.5
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)

//: Connect the sampler to the main output
AudioKit.output = reverb
AudioKit.start()

//: This is a loop to send a random note to the sampler
//: The sampler 'playNote' function is very useful here
let scale = [0, 2, 4, 5, 7, 9, 11, 12]

//AKPlaygroundLoop(every: pulse) {
//    var note = scale.randomElement()
//    let octave = randomInt(3...7)  * 12
//    if random(0, 10) < 1.0 { note += 1 }
//    if !scale.contains(note % 12) { print("ACCIDENT!") }
//    if random(0, 6) > 1.0 { sampler.playNote(note + octave) }
//}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
