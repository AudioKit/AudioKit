//: Development
import AudioKit

let oscillator = AKOscillator()
AudioKit.output = oscillator
AudioKit.start()

oscillator.start()
sleep(1)
