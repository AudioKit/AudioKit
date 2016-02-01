//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a delay
let inputMix = AKMixer(mic, player)
var delay = AKDelay(inputMix)

//: Set the parameters of the delay here
delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

var delayWindow  = AKDelayWindow(delay)

//: You can also set the bounds of the sliders here
delayWindow.timeSlider.maxValue = 0.2 // seconds
delayWindow.feedbackSlider.maxValue = 0.99
AudioKit.output = delay
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
