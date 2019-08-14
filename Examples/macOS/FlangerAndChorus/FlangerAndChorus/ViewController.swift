//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

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

        flangerFrequencySlider.minValue = AKFlanger.frequencyRange.lowerBound
        flangerFrequencySlider.maxValue = AKFlanger.frequencyRange.upperBound
        flangerDepthSlider.minValue = AKFlanger.depthRange.lowerBound
        flangerDepthSlider.maxValue = AKFlanger.depthRange.upperBound
        flangerFeedbackSlider.minValue = AKFlanger.feedbackRange.lowerBound
        flangerFeedbackSlider.maxValue = AKFlanger.feedbackRange.upperBound
        flangerDryWetMixSlider.minValue = AKFlanger.dryWetMixRange.lowerBound
        flangerDryWetMixSlider.maxValue = AKFlanger.dryWetMixRange.upperBound

        flangerFrequencySlider.doubleValue = conductor.flanger.frequency
        flangerDepthSlider.doubleValue = conductor.flanger.depth
        flangerDryWetMixSlider.doubleValue = conductor.flanger.dryWetMix
        flangerFeedbackSlider.doubleValue = conductor.flanger.feedback

        flangerFrequencyReadout.doubleValue = conductor.flanger.frequency
        flangerDepthReadout.doubleValue = conductor.flanger.depth
        flangerDryWetMixReadout.doubleValue = conductor.flanger.dryWetMix
        flangerFeedbackReadout.doubleValue = conductor.flanger.feedback

        chorusFrequencySlider.minValue = AKChorus.frequencyRange.lowerBound
        chorusFrequencySlider.maxValue = AKChorus.frequencyRange.upperBound
        chorusDepthSlider.minValue = AKChorus.depthRange.lowerBound
        chorusDepthSlider.maxValue = AKChorus.depthRange.upperBound
        chorusFeedbackSlider.minValue = AKChorus.feedbackRange.lowerBound
        chorusFeedbackSlider.maxValue = AKChorus.feedbackRange.upperBound
        chorusDryWetMixSlider.minValue = AKChorus.dryWetMixRange.lowerBound
        chorusDryWetMixSlider.maxValue = AKChorus.dryWetMixRange.upperBound

        chorusFrequencySlider.doubleValue = conductor.chorus.frequency
        chorusDepthSlider.doubleValue = conductor.chorus.depth
        chorusDryWetMixSlider.doubleValue = conductor.chorus.dryWetMix
        chorusFeedbackSlider.doubleValue = conductor.chorus.feedback

        chorusFrequencyReadout.doubleValue = conductor.chorus.frequency
        chorusDepthReadout.doubleValue = conductor.chorus.depth
        chorusDryWetMixReadout.doubleValue = conductor.chorus.dryWetMix
        chorusFeedbackReadout.doubleValue = conductor.chorus.feedback
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
        conductor.flanger.frequency = flangerFrequencySlider.doubleValue
        flangerFrequencyReadout.doubleValue = flangerFrequencySlider.doubleValue
    }

    @IBAction func on_flModDepthSlider(_ sender: Any) {
        conductor.flanger.depth = flangerDepthSlider.doubleValue
        flangerDepthReadout.doubleValue = flangerDepthSlider.doubleValue
    }

    @IBAction func on_flWetFractionSlider(_ sender: Any) {
        conductor.flanger.dryWetMix = flangerDryWetMixSlider.doubleValue
        flangerDryWetMixReadout.doubleValue = flangerDryWetMixSlider.doubleValue
    }

    @IBAction func on_flFeedbackSlider(_ sender: Any) {
        conductor.flanger.feedback = flangerFeedbackSlider.doubleValue
        flangerFeedbackReadout.doubleValue = flangerFeedbackSlider.doubleValue
    }

    @IBAction func on_chModFreqSlider(_ sender: Any) {
        conductor.chorus.frequency = chorusFrequencySlider.doubleValue
        chorusFrequencyReadout.doubleValue = chorusFrequencySlider.doubleValue
    }

    @IBAction func on_chModDepthSlider(_ sender: Any) {
        conductor.chorus.depth = chorusDepthSlider.doubleValue
        chorusDepthReadout.doubleValue = chorusDepthSlider.doubleValue
    }

    @IBAction func on_chWetFractionSlider(_ sender: Any) {
        conductor.chorus.dryWetMix = chorusDryWetMixSlider.doubleValue
        chorusDryWetMixReadout.doubleValue = chorusDryWetMixSlider.doubleValue
    }

    @IBAction func on_chFeedbackSlider(_ sender: Any) {
        conductor.chorus.feedback = chorusFeedbackSlider.doubleValue
        chorusFeedbackReadout.doubleValue = chorusFeedbackSlider.doubleValue
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
