//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FFT Analysis
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()

let file = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .Resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

AudioKit.output = player
AudioKit.start()
player.play()
let fft = AKFFTTap(player)

AKPlaygroundLoop(every: 0.1) {
    let max = fft.fftData.maxElement()!
    let index = fft.fftData.indexOf(max)
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
