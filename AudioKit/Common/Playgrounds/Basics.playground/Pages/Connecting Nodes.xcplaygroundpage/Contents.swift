//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Connecting Nodes
//: Playing audio is great, but now let's process that audio.
//: Now that you're up and running, let's take it a step further by
//: loading up an audio file and processing it. We're going to do this
//: by connecting nodes together. A node is simply an object that will
//: take in audio input, process it, and pass the processed audio to
//: another node, or to the Digital-Analog Converter (speaker).
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

//: Set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true

//: Next we'll connect the audio player to a delay effect
var delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.1 // seconds
delay.feedback  = 0.8 // Normalized Value 0 - 1
delay.dryWetMix = 0.2 // Normalized Value 0 - 1

//: Continue adding more nodes as you wish, for example, reverb:
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.Cathedral)

AudioKit.output = reverb
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
