// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
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

        flangerFrequencySlider.minValue = Double(AKFlanger.frequencyRange.lowerBound)
        flangerFrequencySlider.maxValue = Double(AKFlanger.frequencyRange.upperBound)
        flangerDepthSlider.minValue = Double(AKFlanger.depthRange.lowerBound)
        flangerDepthSlider.maxValue = Double(AKFlanger.depthRange.upperBound)
        flangerFeedbackSlider.minValue = Double(AKFlanger.feedbackRange.lowerBound)
        flangerFeedbackSlider.maxValue = Double(AKFlanger.feedbackRange.upperBound)
        flangerDryWetMixSlider.minValue = Double(AKFlanger.dryWetMixRange.lowerBound)
        flangerDryWetMixSlider.maxValue = Double(AKFlanger.dryWetMixRange.upperBound)

        flangerFrequencySlider.floatValue = conductor.flanger.frequency.value
        flangerDepthSlider.floatValue = conductor.flanger.depth.value
        flangerDryWetMixSlider.floatValue = conductor.flanger.dryWetMix.value
        flangerFeedbackSlider.floatValue = conductor.flanger.feedback.value

        flangerFrequencyReadout.floatValue = conductor.flanger.frequency.value
        flangerDepthReadout.floatValue = conductor.flanger.depth.value
        flangerDryWetMixReadout.floatValue = conductor.flanger.dryWetMix.value
        flangerFeedbackReadout.floatValue = conductor.flanger.feedback.value

        chorusFrequencySlider.minValue = Double(AKChorus.frequencyRange.lowerBound)
        chorusFrequencySlider.maxValue = Double(AKChorus.frequencyRange.upperBound)
        chorusDepthSlider.minValue = Double(AKChorus.depthRange.lowerBound)
        chorusDepthSlider.maxValue = Double(AKChorus.depthRange.upperBound)
        chorusFeedbackSlider.minValue = Double(AKChorus.feedbackRange.lowerBound)
        chorusFeedbackSlider.maxValue = Double(AKChorus.feedbackRange.upperBound)
        chorusDryWetMixSlider.minValue = Double(AKChorus.dryWetMixRange.lowerBound)
        chorusDryWetMixSlider.maxValue = Double(AKChorus.dryWetMixRange.upperBound)

        chorusFrequencySlider.floatValue = conductor.chorus.frequency.value
        chorusDepthSlider.floatValue = conductor.chorus.depth.value
        chorusDryWetMixSlider.floatValue = conductor.chorus.dryWetMix.value
        chorusFeedbackSlider.floatValue = conductor.chorus.feedback.value

        chorusFrequencyReadout.floatValue = conductor.chorus.frequency.value
        chorusDepthReadout.floatValue = conductor.chorus.depth.value
        chorusDryWetMixReadout.floatValue = conductor.chorus.dryWetMix.value
        chorusFeedbackReadout.floatValue = conductor.chorus.feedback.value
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
        conductor.flanger.frequency.value = flangerFrequencySlider.floatValue
        flangerFrequencyReadout.floatValue = flangerFrequencySlider.floatValue
    }

    @IBAction func on_flModDepthSlider(_ sender: Any) {
        conductor.flanger.depth.value = flangerDepthSlider.floatValue
        flangerDepthReadout.floatValue = flangerDepthSlider.floatValue
    }

    @IBAction func on_flWetFractionSlider(_ sender: Any) {
        conductor.flanger.dryWetMix.value = flangerDryWetMixSlider.floatValue
        flangerDryWetMixReadout.floatValue = flangerDryWetMixSlider.floatValue
    }

    @IBAction func on_flFeedbackSlider(_ sender: Any) {
        conductor.flanger.feedback.value = flangerFeedbackSlider.floatValue
        flangerFeedbackReadout.floatValue = flangerFeedbackSlider.floatValue
    }

    @IBAction func on_chModFreqSlider(_ sender: Any) {
        conductor.chorus.frequency.value = chorusFrequencySlider.floatValue
        chorusFrequencyReadout.floatValue = chorusFrequencySlider.floatValue
    }

    @IBAction func on_chModDepthSlider(_ sender: Any) {
        conductor.chorus.depth.value = chorusDepthSlider.floatValue
        chorusDepthReadout.floatValue = chorusDepthSlider.floatValue
    }

    @IBAction func on_chWetFractionSlider(_ sender: Any) {
        conductor.chorus.dryWetMix.value = chorusDryWetMixSlider.floatValue
        chorusDryWetMixReadout.floatValue = chorusDryWetMixSlider.floatValue
    }

    @IBAction func on_chFeedbackSlider(_ sender: Any) {
        conductor.chorus.feedback.value = chorusFeedbackSlider.floatValue
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
