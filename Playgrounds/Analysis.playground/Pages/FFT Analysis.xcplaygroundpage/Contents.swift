//: ## FFT Analysis
//:

import AudioKit

let file = try AVAudioFile(readFileName: "leadloop.wav")

var player = AudioPlayer(audioFile: file)
player.isLooping = true
player.buffering = .always

engine.output = player
try engine.start()
player.play()
let fft = FFTTap(player)

PlaygroundLoop(every: 0.1) {
    if let max = fft.fftData.max() {
        let index = fft.fftData.index(of: max)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
