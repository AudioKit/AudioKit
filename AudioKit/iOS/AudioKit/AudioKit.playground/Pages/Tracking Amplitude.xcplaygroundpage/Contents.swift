import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let volume = sineWave(frequency:0.2.ak)
let oscillator = sineWave(frequency: 440.ak, amplitude: volume)
let testNode = AKNode.generator(oscillator)

let trackedAmplitude = AKAmplitudeTracker(testNode)

audiokit.audioOutput = trackedAmplitude
audiokit.start()

let updater = AKPlaygroundLoop(every: 0.1) {
    let amp = trackedAmplitude.amplitude
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
