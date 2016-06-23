//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Rolling Output Plot
//: ###  If you open the Assitant editor and make sure it shows the Rolling Output Plot.xcplaygroundpage (Timeline) view, you should see a plot of the amplitude peaks scrolling in the view
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop.wav", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

AudioKit.output = player
AudioKit.start()
player.play()

let plotView = AKRollingOutputPlot.createView()

XCPlaygroundPage.currentPage.liveView = plotView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@ne