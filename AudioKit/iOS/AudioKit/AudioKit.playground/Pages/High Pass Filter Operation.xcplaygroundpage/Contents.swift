//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## highPassFilter
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Filter setup
let cutoff = AKP.scale(AKP.sine(frequency: 0.2.ak), minimumOutput: 12000.ak, maximumOutput: 100.ak)
let filter = AKP.highPassFilter(AKP.input, cutoffFrequency: cutoff)

//: Noise Example
let whiteNoise = AKWhiteNoise(amplitude: 0.1) // Bring down the amplitude so that when it is mixed it is not so loud
let noise = AKP.effect(whiteNoise, operation: filter)
let noiseExample = AKMixer(noise)

//: Music Example
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let filteredPlayer = AKP.effect(player, operation: filter)
let musicExample = AKMixer(filteredPlayer)

//: Change the volumes below to hear the examples
noiseExample.volume = 1
musicExample.volume = 0

//: Mixdown and playback
let mixer = AKMixer(noiseExample, musicExample)
audiokit.audioOutput = mixer
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
