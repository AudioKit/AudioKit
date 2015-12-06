//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAutoWah
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
let wah = AKAutoWah(player)
player.looping = true

//: Set the parameters of the band pass filter here
wah.wah = 1
wah.amplitude = 1

audiokit.audioOutput = wah
audiokit.start()

player.play()

var t = 0.0
while true {
    wah.wah = Float(1.0 - cos(20 * t))
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
