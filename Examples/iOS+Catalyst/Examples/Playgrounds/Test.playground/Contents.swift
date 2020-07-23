import AudioKit

let oscillator = AKOscillator()

AKManager.output = oscillator
try AKManager.start()

oscillator.start()

sleep(1)

oscillator.stop()
