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


let working_tpoly_example = AKOperation(
        "'args' '4.0 60 0.1' gen_vals " +
        "'notes' '60 62 71 64 67 74' gen_vals " +
        "1 metro dup " +
        "0 'notes' tseq  " +
        "1 'args' tset " +
        "4 2 'args' 'poly' tpoly " +
            
        "0 0 'poly' polyget  " +
        "0.1 0 1 'poly' polyget  " +
        "0.2 - " +
        "0.1 tenv " +
        "0 2 'poly' polyget mtof " +
        "0 3 'poly' polyget  " +
        "1 1 1  " +
        "fm " +
        "* " +
            
        "1 0 'poly' polyget  " +
        "0.1 " +
        "1 1 'poly' polyget  " +
        "0.2 - " +
        "0.1  " +
        "tenv  " +
        "1 2 'poly' polyget mtof " +
        "1 3 'poly' polyget  " +
        "1 1 1  " +
        "fm " +
        "* + " +
            
        "2 0 'poly' polyget  " +
        "0.1 " +
        "2 1 'poly' polyget  " +
        "0.2 - " +
        "0.1  " +
        "tenv  " +
        "2 2 'poly' polyget mtof " +
        "2 3 'poly' polyget  " +
        "1 1 1  " +
        "fm " +
        "* + " +
            
        "3 0 'poly' polyget  " +
        "0.1 " +
        "3 1 'poly' polyget  " +
        "0.2 - " +
        "0.1  " +
        "tenv  " +
        "3 2 'poly' polyget mtof " +
        "3 3 'poly' polyget  " +
        "1 1 1  " +
        "fm " +
        "* + " )

func repeatedPiece(x: Int) -> String {
    var s = "(\(x) 0 'poly' polyget)  (0.1 ((\(x) 1 'poly' polyget)  0.2 -) 0.1  tenv)  ((\(x) 2 'poly' polyget) mtof) (\(x) 3 'poly' polyget)  1 1 1  fm * "
    if x > 0 {
        s = s + "+ "
    }
    return s
}

func simplerRepeatedPiece(x: Int) -> String {
    var s = "(\(x) 0 'poly' polyget)  (0.1 ((\(x) 1 'poly' polyget)  0.2 -) 0.1  tenv)  (220 440 1 randh) (\(x) 3 'poly' polyget)  1 1 1  fm * "
    if x > 0 {
        s = s + "+ "
    }
    return s
}


let tpoly_example = AKOperation(
        "'args'  '4.0 60 0.1'         gen_vals " +
        "'notes' '60  62 71 64 67 74' gen_vals " +
        "1 metro dup " +
        "0 'notes' tseq  " +
        "1 'args'  tset " +
        "4 2 'args' 'poly' tpoly " +
        
        repeatedPiece(0) +
        repeatedPiece(1) +
        repeatedPiece(2) +
        repeatedPiece(3)
        )

let simpler_tpoly_example = AKOperation(
    "'args'  '4.0 60 0.1'         gen_vals " +
        "1 metro " +
        "4 2 'args' 'poly' tpoly " +
        
        simplerRepeatedPiece(0) +
        simplerRepeatedPiece(1) +
        simplerRepeatedPiece(2) +
        simplerRepeatedPiece(3)
)

func randomOscillator(voice voice: Int) -> String {
    return "0.01 0.2 0.1 tenv "
}

let generator = AKOperationGenerator(operation: simpler_tpoly_example)

audiokit.audioOutput = generator
audiokit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
