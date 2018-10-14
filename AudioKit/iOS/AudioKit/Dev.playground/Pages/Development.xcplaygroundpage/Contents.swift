//: Development
import AudioKit

let osc = AKOscillator()
osc.amplitude = 0.1
AudioKit.output = osc
osc.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
