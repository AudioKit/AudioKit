//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## lowPassFilter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the high-frequency components of the audio signal, allowing for the lower     frequency components to "pass through" the filter.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Filter setup
let halfPower = AKP.scale(AKP.sine(frequency: 0.2.ak), minimum: 100.ak, maximum: 2000.ak)
let filter = AKP.lowPassFilter(AKP.input, halfPowerPoint: halfPower)

//: Noise Example
let whiteNoise = AKWhiteNoise(amplitude: 0.1) // Bring down the amplitude so that when it is mixed it is not so loud
let noise = AKNode.effect(whiteNoise, operation: filter)
let noiseExample = AKGain(noise)

//: Music Example
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let filteredPlayer = AKNode.effect(player, operation: filter)
let musicExample = AKGain(filteredPlayer)

//: Change the gains below to hear the examples
noiseExample.gain = 1
musicExample.gain = 1

//: Mixdown and playback
let mixer = AKMixer(noiseExample, musicExample)
audiokit.audioOutput = mixer
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
