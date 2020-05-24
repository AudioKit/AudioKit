//: Development
import AudioKit

let oscillator = AKOscillator()

var gainer = AKBooster(oscillator)

AKManager.output = gainer
try AKManager.start()

oscillator.start()
sleep(4)
