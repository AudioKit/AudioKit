//
//  Conductor.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Conductor: AKMIDIListener {
    /// Globally accessible singleton
    static let sharedInstance = Conductor()

    var core = CoreInstrument(voiceCount: 5)
    var bitCrusher: AKBitCrusher
    var fatten: Fatten
    var filterSection: FilterSection
    var multiDelay: MultiDelay
    var multiDelayMixer: AKDryWetMixer

    var masterVolume = AKMixer()
    var reverb: AKCostelloReverb
    var reverbMixer: AKDryWetMixer

    var midiBendRange: Double = 2.0

    init() {
        AKSettings.audioInputEnabled = true
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

        // uncomment this to allow background operation
        // AKSettings.playbackWhileMuted = true

        AudioKit.output = reverbMixer
        AudioKit.start()

        let midi = AKMIDI()
        midi.createVirtualPorts()
        midi.openInput("Session 1")
        midi.addListener(self)
    }
    
    // MARK: - AKMIDIListener protocol functions

    func receivedMIDINoteOn(_ note: Int, velocity: Int, channel: Int) {
        core.playNote(note, velocity: velocity)
    }
    func receivedMIDINoteOff(_ note: Int, velocity: Int, channel: Int) {
        core.stopNote(note)
    }
    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: Int) {
        let bendSemi =  (Double(pitchWheelValue - 8192) / 8192.0) * midiBendRange
        core.globalbend = bendSemi
    }

}
