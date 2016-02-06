//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Telephone
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds.
import XCPlayground
import AudioKit

//: ### Dial Tone
//: A dial tone is simply two sine waves at specific frequencies
let dialTone1 = AKOperation.sineWave(frequency: 350)
let dialTone2 = AKOperation.sineWave(frequency: 440)
let dialToneMix = mixer(dialTone1, dialTone2, balance: 0.5)

let dialTone = AKOperationGenerator(operation: dialToneMix * 0.3)

//: ## Telephone Ringing
//: The ringing sound is also a pair of frequencies that play for 2 seconds, and repeats every 6 seconds.
let ringingTone1 = AKOperation.sineWave(frequency: 480)
let ringingTone2 = AKOperation.sineWave(frequency: 440)

let ringingToneMix = mixer(ringingTone1, ringingTone2, balance: 0.5)

let ringTrigger = AKOperation.metronome(0.1666) // 1 / 6 seconds

let rings = ringingToneMix.triggeredWithEnvelope(ringTrigger,
                                                   attack: 0.01, hold: 2, release: 0.01)

let ringing = AKOperationGenerator(operation: rings * 0.4)

//: ### Busy Signal
//: The busy signal is similar as well, just a different set of parameters.

let busySignalTone1 = AKOperation.sineWave(frequency: 480)
let busySignalTone2 = AKOperation.sineWave(frequency: 620)
let busySignalTone = mixer(busySignalTone1, busySignalTone2, balance: 0.5)

let busyTrigger = AKOperation.metronome(2)
let busySignal = busySignalTone.triggeredWithEnvelope(busyTrigger,
                                                      attack: 0.01, hold: 0.25, release: 0.01)
let busy = AKOperationGenerator(operation: busySignal * 0.4)



//: ## Key presses
//: All the digits are also just combinations of sine waves

//: Here is the canonical specification of DTMF Tones
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

let keyPressTone = AKOperation.sineWave(frequency: AKOperation.parameters(0)) +
    AKOperation.sineWave(frequency: AKOperation.parameters(1))

let momentaryPress = keyPressTone.triggeredWithEnvelope(
    AKOperation.trigger, attack: 0.01, hold: 0.1, release: 0.01)

let keypad = AKOperationGenerator(operation: momentaryPress * 0.4)

AudioKit.output = AKMixer(dialTone, ringing, busy, keypad)
AudioKit.start()
dialTone.start()

keypad.start()
//
////: Let's call Jenny and Mary!
//let phoneNumber = "8675309   3212333 222 333 3212333322321"
//for number in phoneNumber.characters {
//    if keys.keys.contains(String(number)) {
//        generator.trigger(keys[String(number)]!)
//    }
//    usleep(250000)
//}
//
//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Telephone")
        
        addLabel("Dial Tone")
        addButton("Start", action: "startDialTone")
        addButton("Stop",  action: "stopDialTone")

        addLabel("Ringing")
        addButton("Start", action: "startRinging")
        addButton("Stop",  action: "stopRinging")

        addLabel("Busy Signal")
        addButton("Start", action: "startBusySignal")
        addButton("Stop",  action: "stopBusySignal")
        
        addLabel("Keypad")
        addButton("  1  ", action: "touch1")
        addButton("  2  ", action: "touch2")
        addButton("  3  ", action: "touch3")
        addLineBreak()
        addButton("  4  ", action: "touch4")
        addButton("  5  ", action: "touch5")
        addButton("  6  ", action: "touch6")
        addLineBreak()
        addButton("  7  ", action: "touch7")
        addButton("  8  ", action: "touch8")
        addButton("  9  ", action: "touch9")
        addLineBreak()
        addButton("  *  ", action: "touchStar")
        addButton("  0  ", action: "touch0")
        addButton("  #  ", action: "touchHash")
    }

    func startDialTone() {
        dialTone.start()
    }
    func stopDialTone() {
        dialTone.stop()
    }
    
    func startRinging() {
        ringing.start()
    }
    func stopRinging() {
        ringing.stop()
    }
    
    func startBusySignal() {
        busy.start()
    }
    func stopBusySignal() {
        busy.stop()
    }
    func touch1() {
        keypad.trigger(keys["1"]!)
        usleep(250000)
    }
    func touch2() {
        keypad.trigger(keys["2"]!)
        usleep(250000)
    }
    func touch3() {
        keypad.trigger(keys["3"]!)
        usleep(250000)
    }
    
    func touch4() {
        keypad.trigger(keys["4"]!)
        usleep(250000)
    }
    func touch5() {
        keypad.trigger(keys["5"]!)
        usleep(250000)
    }
    func touch6() {
        keypad.trigger(keys["6"]!)
        usleep(250000)
    }
    
    func touch7() {
        keypad.trigger(keys["7"]!)
        usleep(250000)
    }
    func touch8() {
        keypad.trigger(keys["8"]!)
        usleep(250000)
    }
    func touch9() {
        keypad.trigger(keys["9"]!)
        usleep(250000)
    }
    
    func touchStar() {
        keypad.trigger(keys["*"]!)
        usleep(250000)
    }
    func touch0() {
        keypad.trigger(keys["0"]!)
        usleep(250000)
    }
    func touchHash() {
        keypad.trigger(keys["#"]!)
        usleep(250000)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height:700));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
