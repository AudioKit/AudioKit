//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Rolling Output Plot
//: ###  If you open the Assitant editor and make sure it shows the Rolling Output Plot.xcplaygroundpage (Timeline) view, you should see a plot of the amplitude peaks scrolling in the view
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

AudioKit.output = player
AudioKit.start()
player.play()

let plotView = AKRollingOutputPlot.createView()

PlaygroundPage.current.liveView = plotView

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
