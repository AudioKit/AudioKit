//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter Operation
//:
import PlaygroundSupport
import AudioKit

//: Filter setup
let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 100, maximum: 20000)
let filter = AKOperation.input.lowPassFilter(halfPowerPoint: halfPower)

//: Noise Example
let whiteNoise = AKWhiteNoise(amplitude: 0.1) // Bring down the amplitude so that when it is mixed it is not so loud
let filteredNoise = AKOperationEffect(whiteNoise, operation: filter)

//: Music Example
let bundle = Bundle.main()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let filteredPlayer = AKOperationEffect(player, operation: filter)

//: Mixdown and playback
let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
AudioKit.output = mixer
AudioKit.start()

whiteNoise.start()
player.play()


PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
