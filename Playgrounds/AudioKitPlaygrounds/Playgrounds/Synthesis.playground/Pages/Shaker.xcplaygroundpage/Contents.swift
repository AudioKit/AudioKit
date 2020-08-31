//: ## Shaker
//: Experimenting with a physical model of shakers
import AudioKitPlaygrounds
import AudioKit

let playRate = 2.0

let shaker = AKShaker()

var delay = AKDelay(shaker)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)

let performance = AKPeriodicFunction(frequency: playRate) {
    shaker.type = AKShakerType(rawValue: UInt8(random(in: 0...22))) ?? .cabasa
    shaker.trigger(amplitude: random(in: 0...1))
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
