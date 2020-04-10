// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBandPassButterworthFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKBandPassButterworthFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKBandPassButterworthFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var centerFrequency: Double = AKBandPassButterworthFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var bandwidth: Double = AKBandPassButterworthFilter.defaultBandwidth {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createBandPassButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKBandPassButterworthFilterParameter.centerFrequency.rawValue,
            range: AKBandPassButterworthFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKBandPassButterworthFilterParameter.bandwidth.rawValue,
            range: AKBandPassButterworthFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [centerFrequency, bandwidth]))
        centerFrequency.value = Float(AKBandPassButterworthFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKBandPassButterworthFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true }

}
