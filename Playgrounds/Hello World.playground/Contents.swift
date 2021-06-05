//: Run this playground to test AudioKit

import AudioKit
import AudioKitEX
import Foundation

var greeting = "Hello, playground"

let osc = PlaygroundOscillator()
let fader = Fader(osc, gain: 0.3)

let engine = AudioEngine()
engine.output = fader
osc.play()

try! engine.start()

while true {
    osc.frequency = Float.random(in: 200...800)
    fader.gain = 0.3
    usleep(10000)
    fader.$leftGain.ramp(to: 0.0, duration: 0.9)
    fader.$rightGain.ramp(to: 0.0, duration: 0.9)
    sleep(1)
}

