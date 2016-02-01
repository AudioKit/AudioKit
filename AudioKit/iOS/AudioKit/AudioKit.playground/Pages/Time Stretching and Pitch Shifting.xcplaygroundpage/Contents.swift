//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var timePitch = AKTimePitch(player)

//: Set the parameters of the Peak Limiter here
timePitch.rate = 2.0 // rate
timePitch.pitch = -400 // Cents
timePitch.overlap = 8.0 // generic

AudioKit.output = timePitch
AudioKit.start()
player.play()


//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if timePitch.isBypassed {
        timePitch.start()
    } else {
        timePitch.bypass()
    }
    timePitch.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
