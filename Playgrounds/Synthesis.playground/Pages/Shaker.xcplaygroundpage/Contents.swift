//: ## Shaker
//: Experimenting with a physical model of shakers

import AudioKit

let playRate = 2.0

let shaker = Shaker()

var delay = Delay(shaker)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = Reverb(delay)

let performance = PeriodicFunction(frequency: playRate) {
    shaker.type = ShakerType(rawValue: MIDIByte(AUValue.random(in: 0...22))) ?? .cabasa
    shaker.trigger(amplitude: AUValue.random(in: 0...1))
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
