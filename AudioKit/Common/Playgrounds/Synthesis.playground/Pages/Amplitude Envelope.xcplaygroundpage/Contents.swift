//: ## Amplitude Envelope
//: A surprising amount of character can be added to a sound by changing its amplitude over time.  
//: A very common means of defining the shape of amplitude is to use an ADSR envelope which stands for 
//: Attack, Sustain, Decay, Release.
//: * Attack is the amount of time it takes a sound to reach its maximum volume.  An example of a fast attack is a 
//:   piano, where as a cello can have a longer attack time.
//: * Decay is the amount of time after which the peak amplitude is reached for a lower amplitude to arrive.
//: * Sustain is not a time, but a percentage of the peak amplitude that will be the the sustained amplitude.
//: * Release is the amount of time after a note is let go for the sound to die away to zero.

import AudioKit

var fmWithADSR = AKOscillatorBank()
AudioKit.output = AKBooster(fmWithADSR, gain: 5)
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var holdDuration = 1.0

    override func setup() {

        addTitle("ADSR Envelope")

        let adsrView = AKADSRView { att, dec, sus, rel in
            fmWithADSR.attackDuration = att
            fmWithADSR.decayDuration = dec
            fmWithADSR.sustainLevel = sus
            fmWithADSR.releaseDuration = rel
            Swift.print("fmWithADSR.attackDuration  = \(att)")
            Swift.print("fmWithADSR.decayDuration   = \(dec)")
            Swift.print("fmWithADSR.sustainLevel    = \(sus)")
            Swift.print("fmWithADSR.releaseDuration = \(rel)\n")
        }
        adsrView.attackDuration = fmWithADSR.attackDuration
        adsrView.decayDuration = fmWithADSR.decayDuration
        adsrView.releaseDuration = fmWithADSR.releaseDuration
        adsrView.sustainLevel = fmWithADSR.sustainLevel
        addSubview(adsrView)

        let plot = AKRollingOutputPlot.createView(width: 440, height: 330)
        addSubview(plot)

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

    }

    func noteOn(note: MIDINoteNumber) {
        fmWithADSR.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        fmWithADSR.stop(noteNumber: note)
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
