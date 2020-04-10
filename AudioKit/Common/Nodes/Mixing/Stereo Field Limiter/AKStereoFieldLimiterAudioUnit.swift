// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKStereoFieldLimiterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKStereoFieldLimiterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKStereoFieldLimiterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var amount: Double = 1.0 {
        didSet { setParameter(.amount, value: amount) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createStereoFieldLimiterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let amount = AUParameter(
            identifier: "amount",
            name: "Limiting amount",
            address: 0,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)
        setParameterTree(AUParameterTree(children: [amount]))
        amount.value = 1.0
    }

    public override var canProcessInPlace: Bool { return true }

}
