//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FFT Analysis
//:
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("leadloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
AudioKit.output = player
AudioKit.start()
player.play()
let fft = AKFFTTap(player)

//: And here's where we monitor the results of tracking the amplitude.
AKPlaygroundLoop(every: 0.1) {
    let max = fft.fftData.maxElement()!
    let index = fft.fftData.indexOf(max)
}

//: This keeps the playground running so that audio can play for a long time
PlaygroundPage.current.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
