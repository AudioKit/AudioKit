//: [Previous](@previous)
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var noise = AKWhiteNoise(amplitude: 1)
var filt = AKMoogLadder(noise)

filt.resonance = 0.94
filt.inertia = 0.0002 //try changing this to 0.2 to hear how this works

audiokit.audioOutput = filt

audiokit.start()
noise.start()

var i = 0

AKPlaygroundLoop(frequency: 2.66) {
    let freqToggle = i % 2
    let inertiaToggle = i % 16
    if(freqToggle > 0){
        filt.cutoffFrequency = 111
    }else{
        filt.cutoffFrequency = 666
    }
    i++
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [Next](@next)
