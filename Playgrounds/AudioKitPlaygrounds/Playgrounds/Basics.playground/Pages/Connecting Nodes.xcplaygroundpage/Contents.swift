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
import AudioKit
import AVFoundation

let engine = AKEngine()
//let file = try AKAudioFile(readFileName: "drumloop.wav")
let file = try! AVAudioFile(forReading: Bundle.main.url(forResource: "drumloop", withExtension: "wav")!)

//: Set up a player to the loop the file's playback
var player = AKPlayer(audioFile: file)
//player.isLooping = true
//player.buffering = .always

//: Next we'll connect the audio player to a delay effect
var delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.1 // seconds
delay.feedback = 0.5 // Normalized Value 0 - 1
delay.dryWetMix = 0.2 // Normalized Value 0 - 1

//: Continue adding more nodes as you wish, for example, reverb:
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.cathedral)

engine.output = reverb
try engine.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
