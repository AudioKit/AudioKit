//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKBitCrusher
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
let bitcrusher: AKBitCrusher

switch source {
case "mic":
    bitcrusher = AKBitCrusher(mic)
default:
    bitcrusher = AKBitCrusher(player)
}
//: Set the parameters of the band pass filter here
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 8000

audiokit.audioOutput = bitcrusher
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
