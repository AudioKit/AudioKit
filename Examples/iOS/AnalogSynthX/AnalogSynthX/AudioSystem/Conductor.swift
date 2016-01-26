//
//  Conductor.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor {
    /// Globally accessible singleton
    static let sharedInstance = Conductor()

    let audiokit = AKManager.sharedInstance
    var midi = AKMIDI()

    var core = CoreInstrument(voiceCount: 5)
    var bitCrusher: AKBitCrusher
    var fatten: Fatten
    var filterSection: FilterSection
    var multiDelay: MultiDelay
    var multiDelayMixer: AKDryWetMixer

    var masterVolume = AKMixer()
    var reverb: AKCostelloReverb
    var reverbMixer: AKDryWetMixer


    init() {
        midi.openMIDIIn("Session 1")

        bitCrusher = AKBitCrusher(core)
        bitCrusher.stop()

        filterSection = FilterSection(bitCrusher)
        filterSection.output.stop()

        fatten = Fatten(filterSection)
        multiDelay = MultiDelay(fatten)
        multiDelayMixer = AKDryWetMixer(fatten, multiDelay, balance: 0.0)

        masterVolume = AKMixer(multiDelayMixer)
        reverb = AKCostelloReverb(masterVolume)
        reverb.stop()

        reverbMixer = AKDryWetMixer(masterVolume, reverb, balance: 0.0)

        audiokit.audioOutput = reverbMixer
        audiokit.start()

        let defaultCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()

        defaultCenter.addObserverForName(AKMIDIStatus.NoteOn.name(), object:  nil, queue: mainQueue, usingBlock: handleMIDINotification)
        defaultCenter.addObserverForName(AKMIDIStatus.NoteOff.name(), object: nil, queue: mainQueue, usingBlock: handleMIDINotification)

    }

    func handleMIDINotification(notification: NSNotification) {
        let note = Int((notification.userInfo?["note"])! as! NSNumber)
        let velocity = Int((notification.userInfo?["velocity"])! as! NSNumber)
        if notification.name == AKMIDIStatus.NoteOn.name() && velocity > 0 {
            core.playNote(note, velocity: velocity)
        } else if (notification.name == AKMIDIStatus.NoteOn.name() && velocity == 0) || notification.name == AKMIDIStatus.NoteOff.name() {
            core.stopNote(note)
        }
    }

}