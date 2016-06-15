//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sporth Based Generator
//: ### You can also create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth). This is an example of an effect written in Sporth.
import PlaygroundSupport
import AudioKit

let sporth = AKOperation("4 metro 0.003 0.001 0.1 tenv 57 mtof 0.5 1 1 1 fm mul 3 metro 0.003 0.001 0.1 tenv 64 mtof 0.5 1 1 1 fm mul 2 metro 0.003 0.001 0.1 tenv 67 mtof 0.5 1 1 0.8 fm mul \"notes\" \"73 75 76 78\" gen_vals 0.5 metro dup 0.003 0.001 0.1 tenv swap \"notes\" tseq mtof 0.5 1 1 0.8 fm mul mix 0.3 mul")

let generator = AKOperationGenerator(operation: sporth)

AudioKit.output = generator
AudioKit.start()

generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
