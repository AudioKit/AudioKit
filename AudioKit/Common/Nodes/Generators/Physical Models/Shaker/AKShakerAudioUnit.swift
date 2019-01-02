//
//  AKShakerAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

public class AKShakerAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKShakerParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKShakerParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var type: Double = 0 {
        didSet { setParameter(.type, value: type) }
    }
    var amplitude: Double = 1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createShakerDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let type = AUParameterTree.createParameter(
            withIdentifier: "Type",
            name: "type",
            address: AUParameterAddress(0),
            min: 0,
            max: 22,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AUParameterAddress(1),
            min: 0,
            max: 10,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        setParameterTree(AUParameterTree.createTree(withChildren: [type, amplitude]))
        type.value = 0
        amplitude.value = 0.5
    }

    public override var canProcessInPlace: Bool { return true }

}
