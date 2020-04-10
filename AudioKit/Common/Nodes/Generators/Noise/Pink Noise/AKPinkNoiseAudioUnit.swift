// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPinkNoiseAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPinkNoiseParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPinkNoiseParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var amplitude: Double = AKPinkNoise.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createPinkNoiseDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPinkNoiseParameter.amplitude.rawValue,
            range: AKPinkNoise.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [amplitude]))
        amplitude.value = Float(AKPinkNoise.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
