//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKRingModulator
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let ringModulator: AKRingModulator

switch source {
case "mic":
    ringModulator = AKRingModulator(mic)
default:
    playerWindow = AKAudioPlayerWindow(player)
    let playerWithVolumeAndPanControl = AKMixer(player)
    ringModulator = AKRingModulator(playerWithVolumeAndPanControl)
}

//: Set the parameters of the ring modulator here
ringModulator.frequency1 = 440 // Hertz
ringModulator.frequency2 = 660 // Hertz
ringModulator.balance = 50 // Percent
ringModulator.mix = 50 // Percent

var ringModulatorWindow = AKRingModulatorWindow(ringModulator)

audiokit.audioOutput = ringModulator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
