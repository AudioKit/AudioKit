//
//  AKShakerAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

public class AKShakerAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKShakerParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKShakerParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
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

        let type = AUParameter(
            identifier: "Type",
            name: "type",
            address: 0,
            range: 0...22,
            unit: .generic,
            flags: .default)
        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: 1,
            range: 0...10,
            unit: .generic,
            flags: .default)
        setParameterTree(AUParameterTree(children: [type, amplitude]))
        type.value = 0
        amplitude.value = 0.5
    }

    public override var canProcessInPlace: Bool { return true }

}
