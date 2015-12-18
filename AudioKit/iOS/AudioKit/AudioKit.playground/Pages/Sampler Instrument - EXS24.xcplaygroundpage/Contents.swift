//: [Previous](@previous)

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance


//: We are going to load an EXS24 instrument and send it random notes

let sampler = AKSampler()

//: Here is where we reference the EXS24 file as it is in the app bundle
sampler.loadEXS24("Sounds/sawPiano1")

//: Connect the sampler to the main output
audiokit.audioOutput = sampler
audiokit.start()

//: This is a loop to send a random note to the sampler every ~1/3 of a second
//: The sampler 'playNote' function is very useful here
let updater = AKPlaygroundLoop(every: 0.33) {
    sampler.playNote(Int(arc4random_uniform(127)))
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
