//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAutoWah
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
let wah: AKAutoWah

switch source {
case "mic":
    wah = AKAutoWah(mic)
default:
    wah = AKAutoWah(player)
    player.looping = true
}
//: Set the parameters of the band pass filter here
wah.wah = 1
wah.amplitude = 1

audiokit.audioOutput = wah
audiokit.start()

if source == "player" {
    player.play()
}

var t = 0.0
while true {
    wah.wah = Float(1.0 - cos(20 * t))
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
