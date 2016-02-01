//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Bit Crush Effect
//: ### An audio signal consists of two components, amplitude and frequency. When an analog audio signal is converted to a digial representation, these two components are stored by a bit-depth value, and a sample-rate value. The sample-rate represents the number of samples of audio per second, and the bit-depth represents the number of bits used capture that audio. The bit-depth specifies the dynamic range (the difference between the smallest and loudest audio signal). By changing the bit-depth of an audio file, you can create rather interesting digital distortion effects.  
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var bitcrusher = AKBitCrusher(player)

//: Set the parameters of the bitcrusher here
bitcrusher.bitDepth = 16
bitcrusher.sampleRate = 3333

AudioKit.output = bitcrusher
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
