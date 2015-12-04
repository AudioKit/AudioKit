//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## clip
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096), baseFrequency: 100,  amplitude:0.1)
let sine = AKP.sine(frequency: 0.3.ak)
let limitSine = AKP.scale(sine, minimumOutput: 0.ak, maximumOutput: 1.ak)

let clip = AKP.clip(AKP.input, limit: limitSine)
let effect = AKP.effect(player, operation: clip)

audiokit.audioOutput = effect
audiokit.start()
player.play()
while true {
//    fm.baseFrequency.randomize(220, 880)
//    fm.carrierMultiplier.randomize(0, 4)
//    fm.modulationIndex.randomize(0, 5)
//    fm.modulatingMultiplier.randomize(0, 0.3)
//    fm.amplitude.randomize(0, 0.3)
    usleep(UInt32(randomInt(0...160000)))
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
