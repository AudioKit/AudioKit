//: ## Amplitude Envelope
//: A surprising amount of character can be added to a sound by changing its amplitude over time.  
//: A very common means of defining the shape of amplitude is to use an ADSR envelope which stands for 
//: Attack, Sustain, Decay, Release.
//: * Attack is the amount of time it takes a sound to reach its maximum volume.  An example of a fast attack is a 
//:   piano, where as a cello can have a longer attack time.
//: * Decay is the amount of time after which the peak amplitude is reached for a lower amplitude to arrive.
//: * Sustain is not a time, but a percentage of the peak amplitude that will be the the sustained amplitude.
//: * Release is the amount of time after a note is let go for the sound to die away to zero.
import AudioKitPlaygrounds
import AudioKit

var fmWithADSR = AKOscillatorBank()
var amplitudeTracker = AKAmplitudeTracker(fmWithADSR)
AudioKit.output = AKBooster(amplitudeTracker, gain: 5)
AudioKit.start()
amplitudeTracker.start()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var holdDuration = 1.0
    var plot: AKOutputWaveformPlot?

    override func viewDidLoad() {

        let frame = CGRect(x: 0.0, y: 0.0, width: 440, height: 330)
        plot = AKOutputWaveformPlot(frame: frame)

        plot?.plotType = .rolling
        plot?.backgroundColor = AKColor.clear
        plot?.shouldCenterYAxis = true

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
        addView(adsrView)

        addView(plot!)

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addView(keyboard)

    }

    func noteOn(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.plot?.resume()
            fmWithADSR.play(noteNumber: note, velocity: 80)
        }
    }

    func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            fmWithADSR.stop(noteNumber: note)
        }
    }
}

let view = LiveView()

AKPlaygroundLoop(every: 1.0) {
    if amplitudeTracker.amplitude < 0.001 {
        view.plot?.pause()
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
