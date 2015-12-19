//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## DTMF Tones
//: ### An example creating typical telephone sounds with AudioKit
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Now we can move on to dialing sounds
var keys = [String: [Double]]()
keys["1"] = [697, 1209]
keys["2"] = [697, 1336]
keys["3"] = [697, 1477]
keys["4"] = [770, 1209]
keys["5"] = [770, 1336]
keys["6"] = [770, 1477]
keys["7"] = [852, 1209]
keys["8"] = [852, 1336]
keys["9"] = [852, 1477]
keys["*"] = [941, 1209]
keys["0"] = [941, 1336]
keys["#"] = [941, 1477]

let frequencies = keys["0"]!
let keyPressTone = sineWave(frequency: frequencies[0].ak) + sineWave(frequency: frequencies[1].ak)

let generator = AKNode.generator(keyPressTone)

audiokit.audioOutput = generator
audiokit.start()

sleep(1)

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
