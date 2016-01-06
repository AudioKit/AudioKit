//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Fattening Effect Playground
//: ### Needed to test this for the keyboard project
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

//: Here we set up a player to the loop the file's playback
var player = AKAudioPlayer(file!)
player.looping = true

let fattenMix = 0.5
let fattenTime = 0.05
let input = AKStereoOperation.input
let fattenOperation = AKStereoOperation(
    "\(input) dup \(1 - fattenMix) * swap 0 \(fattenTime) delay \(fattenMix) * +")
let fatten = AKOperationEffect(player, stereoOperation: fattenOperation)

audiokit.audioOutput = fatten
audiokit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if fatten.isBypassed {
        fatten.start()
    } else {
        fatten.bypass()
    }
    fatten.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)



