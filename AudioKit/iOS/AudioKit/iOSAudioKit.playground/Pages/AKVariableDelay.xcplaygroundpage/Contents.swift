//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKVariableDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times
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
player.looping = true
let delay: AKVariableDelay

switch source {
case "mic":
    delay = AKVariableDelay(mic)
default:
    delay = AKVariableDelay(player)
}

//: Set the parameters of the delay here
delay.delayTime = 0 // seconds


audiokit.audioOutput = delay
audiokit.start()
if source == "player" {
    player.play()
}
var t = 0.0
while true {
    delay.delayTime = Float(1.0 - cos(t))
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
