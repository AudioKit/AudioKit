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
let keyPressTone = sineWave(frequency: AKOperation.parameters(0)) + sineWave(frequency: AKOperation.parameters(1))
let envelopedTone = AKOperation("0.01 0.1 0.01 tenv \(keyPressTone) mul")
let generator = AKNode.generator(envelopedTone, triggered: true)

audiokit.audioOutput = generator
audiokit.start()

let phoneNumber = "867-5309"
for number in phoneNumber.characters {
    if keys.keys.contains(String(number)) {
        generator.trigger(keys[String(number)]!)
        usleep(250000)
    }
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
