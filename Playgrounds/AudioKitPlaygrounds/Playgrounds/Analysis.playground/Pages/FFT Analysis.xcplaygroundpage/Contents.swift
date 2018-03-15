//: ## FFT Analysis
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "leadloop.wav")

var player = AKPlayer(audioFile: file)
player.isLooping = true

AudioKit.output = player
try AudioKit.start()
player.play()
let fft = AKFFTTap(player)

AKPlaygroundLoop(every: 0.1) {
    if let max = fft.fftData.max() {
        let index = fft.fftData.index(of: max)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
