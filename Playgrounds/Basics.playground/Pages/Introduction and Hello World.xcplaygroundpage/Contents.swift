import AudioKit
import Foundation

let engine = AudioEngine()

let oscillator = Oscillator()

engine.output = oscillator
try engine.start()

oscillator.start()

sleep(1)

oscillator.stop()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
