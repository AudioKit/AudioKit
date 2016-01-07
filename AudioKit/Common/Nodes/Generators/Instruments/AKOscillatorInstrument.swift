//
//  AKOscillatorInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKOscillatorInstrument: AKMidiInstrument{
    public init(table: AKTable, numVoicesInit: Int) {
        super.init(inst: BaseInstrument(table: table), numVoicesInit: numVoicesInit)
    }
    public override func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0 * 0.3
        let voiceEntity = voices[voice] as! BaseInstrument //you'll need to cast the voice to it's original form
        voiceEntity.instrument.frequency = frequency
        voiceEntity.instrument.amplitude = amplitude
        voiceEntity.start()
    }
    public override func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        let voiceEntity = voices[voice] as! BaseInstrument //you'll need to cast the voice to it's original form
        voiceEntity.stop()
    }
}

internal class BaseInstrument: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
    var instrument: AKOscillator
    var adsr: AKAmplitudeEnvelope
    var table: AKTable
    init(table: AKTable) {
        instrument = AKOscillator(table: table)
        adsr = AKAmplitudeEnvelope(instrument, attackDuration: 0.2, decayDuration: 0.2, sustainLevel: 0.8, releaseDuration: 1.0)
        self.table = table
        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = BaseInstrument(table: self.table)
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool {
        return instrument.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    func start() {
        instrument.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    func stop() {
        adsr.stop()
    }
}
