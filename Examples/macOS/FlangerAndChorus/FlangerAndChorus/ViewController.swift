//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

class ViewController: NSViewController {

    let conductor = Conductor.shared
    var playing = false

    @IBOutlet weak var fl_modFreqSlider: NSSlider!
    @IBOutlet weak var fl_modDepthSlider: NSSliderCell!
    @IBOutlet weak var fl_wetFractionSlider: NSSlider!
    @IBOutlet weak var fl_feedbackSlider: NSSlider!
    @IBOutlet weak var fl_modFreqReadout: NSTextField!
    @IBOutlet weak var fl_modDepthReadout: NSTextField!
    @IBOutlet weak var fl_wetFractionReadout: NSTextField!
    @IBOutlet weak var fl_feedbackReadout: NSTextField!
    
    @IBOutlet weak var ch_modFreqSlider: NSSlider!
    @IBOutlet weak var ch_modDepthSlider: NSSliderCell!
    @IBOutlet weak var ch_wetFractionSlider: NSSlider!
    @IBOutlet weak var ch_feedbackSlider: NSSlider!
    @IBOutlet weak var ch_modFreqReadout: NSTextField!
    @IBOutlet weak var ch_modDepthReadout: NSTextField!
    @IBOutlet weak var ch_wetFractionReadout: NSTextField!
    @IBOutlet weak var ch_feedbackReadout: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conductor.midi.addListener(self)

        fl_modFreqSlider.minValue = AKFlanger.MIN_FREQUENCY_HZ
        fl_modFreqSlider.maxValue = AKFlanger.MAX_FREQUENCY_HZ
        fl_modDepthSlider.minValue = AKFlanger.MIN_FRACTION
        fl_modDepthSlider.maxValue = AKFlanger.MAX_FRACTION
        fl_wetFractionSlider.minValue = AKFlanger.MIN_FRACTION
        fl_wetFractionSlider.maxValue = AKFlanger.MAX_FRACTION
        fl_feedbackSlider.minValue = AKFlanger.MIN_FEEDBACK
        fl_feedbackSlider.maxValue = AKFlanger.MAX_FEEDBACK

        fl_modFreqSlider.doubleValue = conductor.flanger.frequency
        fl_modDepthSlider.doubleValue = conductor.flanger.depth
        fl_wetFractionSlider.doubleValue = conductor.flanger.dryWetMix
        fl_feedbackSlider.doubleValue = conductor.flanger.feedback
        
        fl_modFreqReadout.doubleValue = conductor.flanger.frequency
        fl_modDepthReadout.doubleValue = conductor.flanger.depth
        fl_wetFractionReadout.doubleValue = conductor.flanger.dryWetMix
        fl_feedbackReadout.doubleValue = conductor.flanger.feedback

        ch_modFreqSlider.minValue = AKChorus.MIN_FREQUENCY_HZ
        ch_modFreqSlider.maxValue = AKChorus.MAX_FREQUENCY_HZ
        ch_modDepthSlider.minValue = AKChorus.MIN_FRACTION
        ch_modDepthSlider.maxValue = AKChorus.MAX_FRACTION
        ch_wetFractionSlider.minValue = AKChorus.MIN_FRACTION
        ch_wetFractionSlider.maxValue = AKChorus.MAX_FRACTION
        ch_feedbackSlider.minValue = AKChorus.MIN_FEEDBACK
        ch_feedbackSlider.maxValue = AKChorus.MAX_FEEDBACK
        
        ch_modFreqSlider.doubleValue = conductor.chorus.frequency
        ch_modDepthSlider.doubleValue = conductor.chorus.depth
        ch_wetFractionSlider.doubleValue = conductor.chorus.dryWetMix
        ch_feedbackSlider.doubleValue = conductor.chorus.feedback
        
        ch_modFreqReadout.doubleValue = conductor.chorus.frequency
        ch_modDepthReadout.doubleValue = conductor.chorus.depth
        ch_wetFractionReadout.doubleValue = conductor.chorus.dryWetMix
        ch_feedbackReadout.doubleValue = conductor.chorus.feedback
    }
    
    @IBAction func toggleSound(_ sender: NSButton) {
        if (playing) {
            conductor.stopNote(note: 65, channel: 0)
            sender.title = "Play"
            playing = false
        } else {
            conductor.playNote(note: 65, velocity: 127, channel: 0)
            conductor.pitchBend(7210)
            sender.title = "Stop"
            playing = true
        }
        sender.setNeedsDisplay()
    }
    
    @IBAction func on_flModFreqSlider(_ sender: Any) {
        conductor.flanger.frequency = fl_modFreqSlider.doubleValue
        fl_modFreqReadout.doubleValue = fl_modFreqSlider.doubleValue
    }
    
    @IBAction func on_flModDepthSlider(_ sender: Any) {
        conductor.flanger.depth = fl_modDepthSlider.doubleValue
        fl_modDepthReadout.doubleValue = fl_modDepthSlider.doubleValue
    }
    
    @IBAction func on_flWetFractionSlider(_ sender: Any) {
        conductor.flanger.dryWetMix = fl_wetFractionSlider.doubleValue
        fl_wetFractionReadout.doubleValue = fl_wetFractionSlider.doubleValue
    }

    @IBAction func on_flFeedbackSlider(_ sender: Any) {
        conductor.flanger.feedback = fl_feedbackSlider.doubleValue
        fl_feedbackReadout.doubleValue = fl_feedbackSlider.doubleValue
    }
    
    @IBAction func on_chModFreqSlider(_ sender: Any) {
        conductor.chorus.frequency = ch_modFreqSlider.doubleValue
        ch_modFreqReadout.doubleValue = ch_modFreqSlider.doubleValue
    }
    
    @IBAction func on_chModDepthSlider(_ sender: Any) {
        conductor.chorus.depth = ch_modDepthSlider.doubleValue
        ch_modDepthReadout.doubleValue = ch_modDepthSlider.doubleValue
    }
    
    @IBAction func on_chWetFractionSlider(_ sender: Any) {
        conductor.chorus.dryWetMix = ch_wetFractionSlider.doubleValue
        ch_wetFractionReadout.doubleValue = ch_wetFractionSlider.doubleValue
    }
    
    @IBAction func on_chFeedbackSlider(_ sender: Any) {
        conductor.chorus.feedback = ch_feedbackSlider.doubleValue
        ch_feedbackReadout.doubleValue = ch_feedbackSlider.doubleValue
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
        //print("Channel: \(channel+1) controller: \(controller) value: \(value)")
        conductor.controller(controller, value: value)
    }
    
    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        conductor.pitchBend(pitchWheelValue)
    }
    
    // After touch
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.afterTouch(pressure)
    }
    
    // MIDI Setup Change
    func receivedMIDISetupChange() {
        print("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(inputName)
        }
    }
    
}
