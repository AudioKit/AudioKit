//
//  GainAudioUnit2.swift
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation

public class GainAudioUnit2: AK4AudioUnitBase {

    func setParam(addr: GainEffectParam, value: Float) {
        setParameterWithAddress(AUParameterAddress(addr.rawValue), value: value)
    }

    var gain: Float = 1.0 {
        didSet { setParam(addr: GainEffectParam.gain, value: gain) }
    }

    var rampTime: Float = 0.0 {
        didSet { setParam(addr: GainEffectParam.gain, value: gain) }
    }

    public override func initDsp(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createGainEffectDsp(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
        let gain = AUParameterTree.createParameter(withIdentifier: "gain",
                                                   name: "Gain",
                                                   address: AUParameterAddress(0),
                                                   min: 0.0, max: 1.0,
                                                   unit: .linearGain, unitName: nil,
                                                   flags: flags,
                                                   valueStrings: nil, dependentParameters: nil)
        setParameterTree(AUParameterTree.createTree(withChildren: [gain]))
        gain.value = 1.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
