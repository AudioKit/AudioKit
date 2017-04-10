//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Connecting Nodes Part 2
//:
//: The intention of most of the AudioKit Playgrounds is to highlight a particular
//: concept.  To keep things clear, we have kept the amount of code to a minimum.
//: But the flipside of that decision is that code from playgrounds will look a little
//: different from production.  In general, to see best practices, you can check out
//: the AudioKit examples project, but here in this playground we're going to redo 
//: the code from the "Connecting Nodes" playground in a way that is more like how 
//: the code would appear in a project.
import AudioKitPlaygrounds
//: Here we begin the code how it would appear in a project

import AudioKit

// Create a class to handle the audio set up
class AudioEngine {
    
    // Declare your nodes as instance variables
    var player: AKAudioPlayer!
    var delay: AKDelay!
    var reverb: AKReverb!
    
    init() {
        // Set up a player to the loop the file's playback
        do {
            let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)
            player = try AKAudioPlayer(file: file)
        } catch {
            AKLog("File Not Found")
            return
        }
        player.looping = true
        
        // Next we'll connect the audio player to a delay effect
        delay = AKDelay(player)
        
        // Set the parameters of the delay here
        delay.time = 0.1 // seconds
        delay.feedback = 0.8 // Normalized Value 0 - 1
        delay.dryWetMix = 0.2 // Normalized Value 0 - 1
        
        // Continue adding more nodes as you wish, for example, reverb:
        reverb = AKReverb(delay)
        reverb.loadFactoryPreset(.cathedral)
        
        AudioKit.output = reverb
        AudioKit.start()
    }
}

// Create your engine and start the player
let engine = AudioEngine()
engine.player.play()

//: The next few lines are also just for playgrounds

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)