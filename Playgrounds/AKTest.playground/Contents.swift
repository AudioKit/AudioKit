//import Cocoa
import AudioKit
import AudioKitEX
import PlaygroundSupport

var greeting = "Hello, playground"

let osc = PlaygroundOscillator()
let fader = Fader(osc)
fader.gain = 0.2
let engine = AudioEngine()
engine.output = fader
osc.play()

try! engine.start()

//sleep(2)
PlaygroundPage.current.needsIndefiniteExecution = true
