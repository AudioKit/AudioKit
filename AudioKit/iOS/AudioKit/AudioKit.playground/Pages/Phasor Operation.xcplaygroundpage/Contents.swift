//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## phasor
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let interval: Double = 2
let numberOfNotes: Double = 24
let startingNote: Double = 48 // C
let frequency = (floor(phasor(frequency: 0.5.ak) * numberOfNotes) * interval  + startingNote).midiNoteNumberToFrequency()
let amplitude = phasor(frequency: 0.5.ak) - 1

var oscillator = sineWave(frequency: frequency, amplitude: amplitude)
oscillator.lowPassFilter(halfPowerPoint: 1600.ak)

//: Set up the nodes
let generator = AKNode.generator(oscillator)

audiokit.audioOutput = generator
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
