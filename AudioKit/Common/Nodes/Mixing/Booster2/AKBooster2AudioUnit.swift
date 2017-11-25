//
//  AKBooster2AudioUnit.swift
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBooster2AudioUnit: AKAudioUnitBase {

    func setParam(addr: AKBoosterParameter, value: Float) {
        setParameterWithAddress(AUParameterAddress(addr.rawValue), value: value)
    }

    func setParamImmediate(addr: AKBoosterParameter, value: Float) {
        setParamWithAddressImmediate(AUParameterAddress(addr.rawValue), value: value)
    }

    var leftGain: Float = 1.0 {
        didSet { setParam(addr: AKBoosterParameter.leftGain, value: leftGain) }
    }

    var rightGain: Float = 1.0 {
        didSet { setParam(addr: AKBoosterParameter.rightGain, value: rightGain) }
    }

    var rampTime: Float = 0.0 {
        didSet { setParam(addr: AKBoosterParameter.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createBoosterDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
        let leftGain = AUParameterTree.createParameter(withIdentifier: "leftGain",
                                                       name: "Left Boosting Amount",
                                                       address: AUParameterAddress(0),
                                                       min: 0.0, max: 2.0,
                                                       unit: .linearGain, unitName: nil,
                                                       flags: flags,
                                                       valueStrings: nil, dependentParameters: nil)
        let rightGain = AUParameterTree.createParameter(withIdentifier: "rightGain",
                                                        name: "Right Boosting Amount",
                                                        address: AUParameterAddress(1),
                                                        min: 0.0, max: 2.0,
                                                        unit: .linearGain, unitName: nil,
                                                        flags: flags,
                                                        valueStrings: nil, dependentParameters: nil)
        setParameterTree(AUParameterTree.createTree(withChildren: [leftGain, rightGain]))
        leftGain.value = 1.0
        rightGain.value = 1.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
