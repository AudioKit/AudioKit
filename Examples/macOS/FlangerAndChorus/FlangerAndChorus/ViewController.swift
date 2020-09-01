// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import Cocoa

class ViewController: NSViewController {

    let conductor = Conductor.shared
    var playing = false
    @IBOutlet var plot: AKNodeOutputPlot?
    @IBOutlet weak var flangerFrequencySlider: NSSlider!
    @IBOutlet weak var flangerDepthSlider: NSSliderCell!
    @IBOutlet weak var flangerDryWetMixSlider: NSSlider!
    @IBOutlet weak var flangerFeedbackSlider: NSSlider!
    @IBOutlet weak var flangerFrequencyReadout: NSTextField!
    @IBOutlet weak var flangerDepthReadout: NSTextField!
    @IBOutlet weak var flangerDryWetMixReadout: NSTextField!
    @IBOutlet weak var flangerFeedbackReadout: NSTextField!

    @IBOutlet weak var chorusFrequencySlider: NSSlider!
    @IBOutlet weak var chorusDepthSlider: NSSliderCell!
    @IBOutlet weak var chorusDryWetMixSlider: NSSlider!
    @IBOutlet weak var chorusFeedbackSlider: NSSlider!
    @IBOutlet weak var chorusFrequencyReadout: NSTextField!
    @IBOutlet weak var chorusDepthReadout: NSTextField!
    @IBOutlet weak var chorusDryWetMixReadout: NSTextField!
    @IBOutlet weak var chorusFeedbackReadout: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        conductor.midi.addListener(self)
        let flanger = AKFlanger()
        let chorus = AKChorus()

        flangerFrequencySlider.minValue = Double(flanger.$frequency.minValue)
        flangerFrequencySlider.maxValue = Double(flanger.$frequency.maxValue)
        flangerDepthSlider.minValue = Double(flanger.$depth.minValue)
        flangerDepthSlider.maxValue = Double(flanger.$depth.maxValue)
        flangerFeedbackSlider.minValue = Double(flanger.$feedback.minValue)
        flangerFeedbackSlider.maxValue = Double(flanger.$feedback.maxValue)
        flangerDryWetMixSlider.minValue = Double(flanger.$dryWetMix.minValue)
        flangerDryWetMixSlider.maxValue = Double(flanger.$dryWetMix.maxValue)

        flangerFrequencySlider.floatValue = conductor.flanger.frequency
        flangerDepthSlider.floatValue = conductor.flanger.depth
        flangerDryWetMixSlider.floatValue = conductor.flanger.dryWetMix
        flangerFeedbackSlider.floatValue = conductor.flanger.feedback

        flangerFrequencyReadout.floatValue = conductor.flanger.frequency
        flangerDepthReadout.floatValue = conductor.flanger.depth
        flangerDryWetMixReadout.floatValue = conductor.flanger.dryWetMix
        flangerFeedbackReadout.floatValue = conductor.flanger.feedback

        chorusFrequencySlider.minValue = Double(chorus.$frequency.minValue)
        chorusFrequencySlider.maxValue = Double(chorus.$frequency.maxValue)
        chorusDepthSlider.minValue = Double(chorus.$depth.minValue)
        chorusDepthSlider.maxValue = Double(chorus.$depth.maxValue)
        chorusFeedbackSlider.minValue = Double(chorus.$feedback.minValue)
        chorusFeedbackSlider.maxValue = Double(chorus.$feedback.maxValue)
        chorusDryWetMixSlider.minValue = Double(chorus.$dryWetMix.minValue)
        chorusDryWetMixSlider.maxValue = Double(chorus.$dryWetMix.maxValue)

        chorusFrequencySlider.floatValue = conductor.chorus.frequency
        chorusDepthSlider.floatValue = conductor.chorus.depth
        chorusDryWetMixSlider.floatValue = conductor.chorus.dryWetMix
        chorusFeedbackSlider.floatValue = conductor.chorus.feedback

        chorusFrequencyReadout.floatValue = conductor.chorus.frequency
        chorusDepthReadout.floatValue = conductor.chorus.depth
        chorusDryWetMixReadout.floatValue = conductor.chorus.dryWetMix
        chorusFeedbackReadout.floatValue = conductor.chorus.feedback
    }

    @IBAction func toggleSound(_ sender: NSButton) {
        if (playing) {
            conductor.stopNote(note: 65, channel: 0)
            sender.title = "Play"
            playing = false
        } else {
            conductor.playNote(note: 65, velocity: 127, channel: 0)
            conductor.pitchBend(7_210)
            sender.title = "Stop"
            playing = true
        }
        sender.setNeedsDisplay()
    }

    @IBAction func on_flModFreqSlider(_ sender: Any) {
        conductor.flanger.frequency = flangerFrequencySlider.floatValue
        flangerFrequencyReadout.floatValue = flangerFrequencySlider.floatValue
    }

    @IBAction func on_flModDepthSlider(_ sender: Any) {
        conductor.flanger.depth = flangerDepthSlider.floatValue
        flangerDepthReadout.floatValue = flangerDepthSlider.floatValue
    }

    @IBAction func on_flWetFractionSlider(_ sender: Any) {
        conductor.flanger.dryWetMix = flangerDryWetMixSlider.floatValue
        flangerDryWetMixReadout.floatValue = flangerDryWetMixSlider.floatValue
    }

    @IBAction func on_flFeedbackSlider(_ sender: Any) {
        conductor.flanger.feedback = flangerFeedbackSlider.floatValue
        flangerFeedbackReadout.floatValue = flangerFeedbackSlider.floatValue
    }

    @IBAction func on_chModFreqSlider(_ sender: Any) {
        conductor.chorus.frequency = chorusFrequencySlider.floatValue
        chorusFrequencyReadout.floatValue = chorusFrequencySlider.floatValue
    }

    @IBAction func on_chModDepthSlider(_ sender: Any) {
        conductor.chorus.depth = chorusDepthSlider.floatValue
        chorusDepthReadout.floatValue = chorusDepthSlider.floatValue
    }

    @IBAction func on_chWetFractionSlider(_ sender: Any) {
        conductor.chorus.dryWetMix = chorusDryWetMixSlider.floatValue
        chorusDryWetMixReadout.floatValue = chorusDryWetMixSlider.floatValue
    }

    @IBAction func on_chFeedbackSlider(_ sender: Any) {
        conductor.chorus.feedback = chorusFeedbackSlider.floatValue
        chorusFeedbackReadout.floatValue = chorusFeedbackSlider.floatValue
    }
}

extension ViewController: AKMIDIListener {

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: noteNumber, velocity: velocity, channel: channel)
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: noteNumber, channel: channel)
        }
    }

    // MIDI Controller input
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        //AKLog("Channel: \(channel+1) controller: \(controller) value: \(value)")
        conductor.controller(controller, value: value)
    }

    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        conductor.pitchBend(pitchWheelValue)
    }

    // After touch
    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.aftertouch(pressure)
    }

    // MIDI Setup Change
    func receivedMIDISetupChange() {
        AKLog("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(name: inputName)
        }
    }

}
