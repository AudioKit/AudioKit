//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node Output Plot
//: ### What's interesting here is that we're plotting the waveform BEFORE the delay is processed
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "drumloop.wav", fromBaseDirectory: .resources)

//: Here we set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true


var delay = AKDelay(player)

delay.time = 0.1 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()


let plot = AKNodeOutputPlot(player, frame: CGRect.init(x: 0, y: 0, width: 500, height: 500))
plot.plotType = .Rolling
plot.shouldFill = true
plot.shouldMirror = true
plot.color = UIColor.blueColor()

XCPlaygroundPage.currentPage.liveView = plot

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@ne
