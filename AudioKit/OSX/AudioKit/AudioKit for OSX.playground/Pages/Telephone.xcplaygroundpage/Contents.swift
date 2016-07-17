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

let keyPressTone = AKOperation.sineWave(frequency: AKOperation.parameters(1)) +
    AKOperation.sineWave(frequency: AKOperation.parameters(2))

let momentaryPress = keyPressTone.triggeredWithEnvelope(
    AKOperation.trigger, attack: 0.01, hold: 0.1, release: 0.01)

let keypad = AKOperationGenerator(operation: momentaryPress * 0.4)

AudioKit.output = AKMixer(dialTone, ringing, busy, keypad)
AudioKit.start()
dialTone.start()

keypad.start()


//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Telephone")

        addLabel("Dial Tone")
        addButton("Start", action: #selector(startDialTone))
        addButton("Stop",  action: #selector(stopDialTone))

        addLabel("Ringing")
        addButton("Start", action: #selector(startRinging))
        addButton("Stop",  action: #selector(stopRinging))

        addLabel("Busy Signal")
        addButton("Start", action: #selector(startBusySignal))
        addButton("Stop",  action: #selector(stopBusySignal))
        addLineBreak()

        addLabel("Keypad")

        addTouchKey("1", text: "",    action: #selector(touch1))
        addTouchKey("2", text: "ABC", action: #selector(touch2))
        addTouchKey("3", text: "DEF", action: #selector(touch3))
        addLineBreak()
        addTouchKey("4", text: "GHI", action: #selector(touch4))
        addTouchKey("5", text: "JKL", action: #selector(touch5))
        addTouchKey("6", text: "MNO", action: #selector(touch6))
        addLineBreak()
        addTouchKey("7", text: "PQRS", action: #selector(touch7))
        addTouchKey("8", text: "TUV",  action: #selector(touch8))
        addTouchKey("9", text: "WXYZ", action: #selector(touch9))
        addLineBreak()
        addTouchKey("*", text: "GHI", action: #selector(touchStar))
        addTouchKey("0", text: "JKL", action: #selector(touch0))
        addTouchKey("#", text: "MNO", action: #selector(touchHash))
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
    
    func touchCall() {
        busy.stop()
        dialTone.stop()
        if ringing.isStarted {
            ringing.stop()
            dialTone.start()
        } else {
            ringing.start()
        }
    }
    
    func touchBusy() {
        ringing.stop()
        dialTone.stop()
        if busy.isStarted {
            busy.stop()
            dialTone.start()
        } else {
            busy.start()
        }
    }
    
    func touchKeyPad(text: String) {
        dialTone.stop()
        ringing.stop()
        busy.stop()
        keypad.parameters[1] = keys[text]![0]
        keypad.parameters[2] = keys[text]![1]
        keypad.trigger()
        usleep(250000)
    }
    
    func touch1() { touchKeyPad("1") }
    func touch2() { touchKeyPad("2") }
    func touch3() { touchKeyPad("3") }
    
    func touch4() { touchKeyPad("4") }
    func touch5() { touchKeyPad("5") }
    func touch6() { touchKeyPad("6") }
    
    func touch7() { touchKeyPad("7") }
    func touch8() { touchKeyPad("8") }
    func touch9() { touchKeyPad("9") }
    
    func touchStar() { touchKeyPad("*") }
    func touch0() { touchKeyPad("0") }
    func touchHash() { touchKeyPad("#") }
}



let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 850))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
