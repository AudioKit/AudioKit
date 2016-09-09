//: ## Telephone
//: AudioKit is great for sound design. This playground creates canonical telephone sounds.
import XCPlayground
import AudioKit

//: ### Dial Tone
//: A dial tone is simply two sine waves at specific frequencies
let dialTone = AKOperationGenerator() { _ in
    let dialTone1 = AKOperation.sineWave(frequency: 350)
    let dialTone2 = AKOperation.sineWave(frequency: 440)
    return mixer(dialTone1, dialTone2) * 0.3
}

//: ### Telephone Ringing
//: The ringing sound is also a pair of frequencies that play for 2 seconds,
//: and repeats every 6 seconds.
let ringing = AKOperationGenerator() { _ in
    let ringingTone1 = AKOperation.sineWave(frequency: 480)
    let ringingTone2 = AKOperation.sineWave(frequency: 440)

    let ringingToneMix = mixer(ringingTone1, ringingTone2)

    let ringTrigger = AKOperation.metronome(frequency: 0.1666) // 1 / 6 seconds

    let rings = ringingToneMix.triggeredWithEnvelope(
        trigger: ringTrigger,
        attack: 0.01, hold: 2, release: 0.01)

    return rings * 0.4
}


//: ### Busy Signal
//: The busy signal is similar as well, just a different set of parameters.
let busy = AKOperationGenerator() { _ in
    let busySignalTone1 = AKOperation.sineWave(frequency: 480)
    let busySignalTone2 = AKOperation.sineWave(frequency: 620)
    let busySignalTone = mixer(busySignalTone1, busySignalTone2)

    let busyTrigger = AKOperation.metronome(frequency: 2)
    let busySignal = busySignalTone.triggeredWithEnvelope(
        trigger: busyTrigger,
        attack: 0.01, hold: 0.25, release: 0.01)
    return busySignal * 0.4
}
//: ## Key presses
//: All the digits are also just combinations of sine waves
//:
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

let keypad = AKOperationGenerator() { parameters in

    let keyPressTone = AKOperation.sineWave(frequency: AKOperation.parameters[1]) +
        AKOperation.sineWave(frequency: AKOperation.parameters[2])

    let momentaryPress = keyPressTone.triggeredWithEnvelope(
        trigger:AKOperation.trigger, attack: 0.01, hold: 0.1, release: 0.01)
    return momentaryPress * 0.4
}

AudioKit.output = AKMixer(dialTone, ringing, busy, keypad)
AudioKit.start()
dialTone.start()

keypad.start()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Telephone")
        addSubview(AKTelephoneView() { key, state in
            switch key {
            case "CALL":
                if state == "down" {
                    busy.stop()
                    dialTone.stop()
                    if ringing.isStarted {
                        ringing.stop()
                        dialTone.start()
                    } else {
                        ringing.start()
                    }
                }

            case "BUSY":
                if state == "down" {
                    ringing.stop()
                    dialTone.stop()
                    if busy.isStarted {
                        busy.stop()
                        dialTone.start()
                    } else {
                        busy.start()
                    }
                }

            default:
                if state == "down" {
                    dialTone.stop()
                    ringing.stop()
                    busy.stop()
                    keypad.parameters[1] = keys[key]![0]
                    keypad.parameters[2] = keys[key]![1]
                    keypad.parameters[0] = 1
                } else {
                    keypad.parameters[0] = 0
                }
        }
        })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
