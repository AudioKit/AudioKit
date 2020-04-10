// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKResonantFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKResonantFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKResonantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKResonantFilter.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var bandwidth: Double = AKResonantFilter.defaultBandwidth {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createResonantFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Center frequency of the filter, or frequency position of the peak response.",
            address: AKResonantFilterParameter.frequency.rawValue,
            range: AKResonantFilter.frequencyRange,
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth of the filter.",
            address: AKResonantFilterParameter.bandwidth.rawValue,
            range: AKResonantFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, bandwidth]))
        frequency.value = Float(AKResonantFilter.defaultFrequency)
        bandwidth.value = Float(AKResonantFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true }

}
