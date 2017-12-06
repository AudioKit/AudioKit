//: Development
import AudioKit

let oscillator = AKOscillator()

var gainer = AKBooster2(oscillator)

AudioKit.output = gainer
AudioKit.start()

oscillator.start()
sleep(4)
