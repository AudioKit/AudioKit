import AudioKit
import Foundation

let osc = PlaygroundOscillator()

let engine = AudioEngine()
engine.output = osc
try! engine.start()

osc.play()

while true {
    osc.frequency = Float.random(in: 200 ... 800)
    osc.amplitude = Float.random(in: 0.0 ... 0.3)
    usleep(100_000)
}
