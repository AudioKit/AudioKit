//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKOperationGenerator
//: ### Just as you can create effect nodes with Sporth for AudioKit, you can also create custom generators.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let simple_sine_example = "0.1 1 sine 110 1760 biscale 0.6 sine dup"

let maygate_example = AKOperation("\"scale\" \"60 62 64 67 71 74\" gen_vals 96 60 div  metro 0.5 1 maygate dup dup 1 \"scale\" tseq swap 0.01 0.1 0.4 tenv swap mtof 0.2 1 1 1 fm mul dup rot 0.8 0 maygate mul dup 0.93 10000 revsc drop 0.3 mul add")
let metro_example = AKOperation("4 metro 0.003 0.001 0.1 tenv 57 mtof 0.5 1 1 1 fm mul 3 metro 0.003 0.001 0.1 tenv 64 mtof 0.5 1 1 1 fm mul 2 metro 0.003 0.001 0.1 tenv 67 mtof 0.5 1 1 0.8 fm mul \"notes\" \"73 75 76 78\" gen_vals 0.5 metro dup 0.003 0.001 0.1 tenv swap \"notes\" tseq mtof 0.5 1 1 0.8 fm mul mix 0.3 mul")
let generator = AKOperationGenerator(operation: metro_example)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
