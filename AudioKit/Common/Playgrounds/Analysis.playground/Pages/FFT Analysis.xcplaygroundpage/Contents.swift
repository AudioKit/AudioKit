//: ## FFT Analysis
//:
import AudioKit

let file = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

AudioKit.output = player
AudioKit.start()
player.play()
let fft = AKFFTTap(player)

AKPlaygroundLoop(every: 0.1) {
    let max = fft.fftData.max()!
    let index = fft.fftData.index(of: max)
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
