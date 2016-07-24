//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Metal Bar Physical Model
//: ### Experimental Playground, not quite working yet.
//:
import AudioKit
import XCPlayground

let playRate = 2.0

let bar = AKMetalBar()

bar.position = 0.001
bar.strikeWidth = 0.0001
bar.decayDuration = 0
bar.leftBoundaryCondition = 1
bar.rightBoundaryCondition = 1

AudioKit.output = bar
AudioKit.start()

AKPlaygroundLoop(frequency: playRate) {
    bar.trigger()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
