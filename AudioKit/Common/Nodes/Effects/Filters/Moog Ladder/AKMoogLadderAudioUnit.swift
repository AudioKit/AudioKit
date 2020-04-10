// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKMoogLadderAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKMoogLadderParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKMoogLadderParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var cutoffFrequency: Double = AKMoogLadder.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKMoogLadder.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createMoogLadderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKMoogLadderParameter.cutoffFrequency.rawValue,
            range: AKMoogLadder.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        let resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance (%)",
            address: AKMoogLadderParameter.resonance.rawValue,
            range: AKMoogLadder.resonanceRange,
            unit: .percent,
            flags: .default)

        setParameterTree(AUParameterTree(children: [cutoffFrequency, resonance]))
        cutoffFrequency.value = Float(AKMoogLadder.defaultCutoffFrequency)
        resonance.value = Float(AKMoogLadder.defaultResonance)
    }

    public override var canProcessInPlace: Bool { return true }

}
