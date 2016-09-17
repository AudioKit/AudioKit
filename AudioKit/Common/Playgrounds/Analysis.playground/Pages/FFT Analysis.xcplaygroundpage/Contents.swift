//: ## FFT Analysis
//:
import PlaygroundSupport
import AudioKit

let bundle = NSBundle.mainBundle()

let file = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .resources)

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

PlaygroundPage.current.needsIndefiniteExecution = true
