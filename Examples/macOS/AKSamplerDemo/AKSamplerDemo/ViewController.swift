//
//  ViewController.swift
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-01-23.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit
import AudioKitUI

class ViewController: NSViewController, NSWindowDelegate {

    let conductor = Conductor.shared
    let sampler = Conductor.shared.sampler

    @IBOutlet weak var sampleSetPopup: NSPopUpButton!

    @IBOutlet weak var masterVolumeSlider: NSSlider!
    @IBOutlet weak var masterVolumeReadout: NSTextField!
    @IBOutlet weak var pitchOffsetSlider: NSSlider!
    @IBOutlet weak var pitchOffsetReadout: NSTextField!
    @IBOutlet weak var vibratoDepthSlider: NSSlider!
    @IBOutlet weak var vibratoDepthReadout: NSTextField!

    @IBOutlet weak var filterEnableCheckbox: NSButton!
    @IBOutlet weak var filterCutoffSlider: NSSlider!
    @IBOutlet weak var filterCutoffReadout: NSTextField!

    @IBOutlet weak var ampAttackSlider: NSSlider!
    @IBOutlet weak var ampAttackReadout: NSTextField!
    @IBOutlet weak var ampDecaySlider: NSSlider!
    @IBOutlet weak var ampDecayReadout: NSTextField!
    @IBOutlet weak var ampSustainSlider: NSSlider!
    @IBOutlet weak var ampSustainReadout: NSTextField!
    @IBOutlet weak var ampReleaseSlider: NSSlider!
    @IBOutlet weak var ampReleaseReadout: NSTextField!

    @IBOutlet weak var filterAttackSlider: NSSlider!
    @IBOutlet weak var filterAttackReadout: NSTextField!
    @IBOutlet weak var filterDecaySlider: NSSlider!
    @IBOutlet weak var filterDecayReadout: NSTextField!
    @IBOutlet weak var filterSustainSlider: NSSlider!
    @IBOutlet weak var filterSustainReadout: NSTextField!
    @IBOutlet weak var filterReleaseSlider: NSSlider!
    @IBOutlet weak var filterReleaseReadout: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        conductor.midi.addListener(self)

        sampleSetPopup.removeAllItems()
        sampleSetPopup.addItem(withTitle: "Brass")
        sampleSetPopup.addItem(withTitle: "LoTine")
        sampleSetPopup.addItem(withTitle: "Metalimba")
        sampleSetPopup.addItem(withTitle: "Pluck Brass")

        sampler.filterCutoff = 100.0

        masterVolumeSlider.intValue = Int32(100 * sampler.masterVolume)
        masterVolumeReadout.intValue = Int32(100 * sampler.masterVolume)
        pitchOffsetSlider.doubleValue = sampler.pitchBend
        pitchOffsetReadout.doubleValue = sampler.pitchBend
        vibratoDepthSlider.doubleValue = sampler.vibratoDepth
        vibratoDepthReadout.doubleValue = sampler.vibratoDepth
        filterEnableCheckbox.state = sampler.filterEnable ? .on : .off
        filterCutoffSlider.intValue = Int32(sampler.filterCutoff)
        filterCutoffReadout.intValue = Int32(sampler.filterCutoff)

        ampAttackSlider.doubleValue = sampler.ampAttackTime
        ampAttackReadout.doubleValue = sampler.ampAttackTime
        ampDecaySlider.doubleValue = sampler.ampDecayTime
        ampDecayReadout.doubleValue = sampler.ampDecayTime
        ampSustainSlider.intValue = Int32(100 * sampler.ampSustainLevel)
        ampSustainReadout.intValue = Int32(100 * sampler.ampSustainLevel)
        ampReleaseSlider.doubleValue = sampler.ampReleaseTime
        ampReleaseReadout.doubleValue = sampler.ampReleaseTime

        filterAttackSlider.doubleValue = sampler.filterAttackTime
        filterAttackReadout.doubleValue = sampler.filterAttackTime
        filterDecaySlider.doubleValue = sampler.filterDecayTime
        filterDecayReadout.doubleValue = sampler.filterDecayTime
        filterSustainSlider.intValue = Int32(100 * sampler.filterSustainLevel)
        filterSustainReadout.intValue = Int32(100 * sampler.filterSustainLevel)
        filterReleaseSlider.doubleValue = sampler.filterReleaseTime
        filterReleaseReadout.doubleValue = sampler.filterReleaseTime
    }

    override func viewDidAppear() {
        self.view.window?.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    @IBAction func onSampleSetSelect(_ sender: NSPopUpButton) {
        conductor.loadSamples(byIndex: sender.indexOfSelectedItem)
    }

    @IBAction func onVolumeSliderChange(_ sender: NSSlider) {
        masterVolumeReadout.intValue = sender.intValue
        sampler.masterVolume = sender.doubleValue / 100.0
    }

    @IBAction func onPitchOffsetSliderChange(_ sender: NSSlider) {
        pitchOffsetReadout.floatValue = sender.floatValue
        sampler.pitchBend = sender.doubleValue
    }

    @IBAction func onVibratoDepthSliderChange(_ sender: NSSlider) {
        vibratoDepthReadout.floatValue = sender.floatValue
        sampler.vibratoDepth = sender.doubleValue
    }

    @IBAction func onFilterEnableCheckChange(_ sender: NSButton) {
        sampler.filterEnable = sender.state == .on
    }

    @IBAction func onFilterCutoffSliderChange(_ sender: NSSlider) {
        filterCutoffReadout.intValue = sender.intValue
        sampler.filterCutoff = sender.doubleValue
    }

    @IBAction func onAmpAttackSliderChange(_ sender: NSSlider) {
        ampAttackReadout.floatValue = sender.floatValue
        sampler.ampAttackTime = sender.doubleValue
    }

    @IBAction func onAmpDecaySliderChange(_ sender: NSSlider) {
        ampDecayReadout.floatValue = sender.floatValue
        sampler.ampDecayTime = sender.doubleValue
    }

    @IBAction func onAmpSustainSliderChange(_ sender: NSSlider) {
        ampSustainReadout.intValue = sender.intValue
        sampler.ampSustainLevel = sender.doubleValue / 100.0
    }

    @IBAction func onAmpReleaseSliderChange(_ sender: NSSlider) {
        ampReleaseReadout.floatValue = sender.floatValue
        sampler.ampReleaseTime = sender.doubleValue
    }

    @IBAction func onFilterAttackSliderChange(_ sender: NSSlider) {
        filterAttackReadout.floatValue = sender.floatValue
        sampler.filterAttackTime = sender.doubleValue
    }

    @IBAction func onFilterDecaySliderChange(_ sender: NSSlider) {
        filterDecayReadout.floatValue = sender.floatValue
        sampler.filterDecayTime = sender.doubleValue
    }

    @IBAction func onFilterSustainSliderChange(_ sender: NSSlider) {
        filterSustainReadout.intValue = sender.intValue
        sampler.filterSustainLevel = sender.doubleValue / 100.0
    }

    @IBAction func onFilterReleaseSliderChange(_ sender: NSSlider) {
        filterReleaseReadout.floatValue = sender.floatValue
        sampler.filterReleaseTime = sender.doubleValue
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
        // Mod wheel can affect both vibrato and filter cutoff
        DispatchQueue.main.async(execute: {
            self.vibratoDepthSlider.doubleValue = self.sampler.vibratoDepth
            self.vibratoDepthReadout.doubleValue = self.sampler.vibratoDepth
            self.filterCutoffSlider.intValue = Int32(self.sampler.filterCutoff)
            self.filterCutoffReadout.intValue = Int32(self.sampler.filterCutoff)
        })
    }

    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        conductor.pitchBend(pitchWheelValue)
        DispatchQueue.main.async(execute: {
            self.pitchOffsetSlider.doubleValue = self.sampler.pitchBend
            self.pitchOffsetReadout.doubleValue = self.sampler.pitchBend
        })
    }

    // After touch
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.afterTouch(pressure)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        // do nothing: silence superclass's log chatter
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
