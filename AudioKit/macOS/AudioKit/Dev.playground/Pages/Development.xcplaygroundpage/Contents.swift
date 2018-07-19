//: Development
import AudioKit

let oscillator = AKOscillator()

var gainer = AKBooster(oscillator)

AudioKit.output = gainer
try AudioKit.start()

oscillator.start()
sleep(4)
