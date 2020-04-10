// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKRolandTB303FilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var cutoffFrequency: Double = AKRolandTB303Filter.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKRolandTB303Filter.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var distortion: Double = AKRolandTB303Filter.defaultDistortion {
        didSet { setParameter(.distortion, value: distortion) }
    }

    var resonanceAsymmetry: Double = AKRolandTB303Filter.defaultResonanceAsymmetry {
        didSet { setParameter(.resonanceAsymmetry, value: resonanceAsymmetry) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func createDSP() -> AKDSPRef {
        return createRolandTB303FilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKRolandTB303FilterParameter.cutoffFrequency.rawValue,
            range: AKRolandTB303Filter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        let resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance",
            address: AKRolandTB303FilterParameter.resonance.rawValue,
            range: AKRolandTB303Filter.resonanceRange,
            unit: .generic,
            flags: .default)
        let distortion = AUParameter(
            identifier: "distortion",
            name: "Distortion",
            address: AKRolandTB303FilterParameter.distortion.rawValue,
            range: AKRolandTB303Filter.distortionRange,
            unit: .generic,
            flags: .default)
        let resonanceAsymmetry = AUParameter(
            identifier: "resonanceAsymmetry",
            name: "Resonance Asymmetry",
            address: AKRolandTB303FilterParameter.resonanceAsymmetry.rawValue,
            range: AKRolandTB303Filter.resonanceAsymmetryRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [cutoffFrequency, resonance, distortion, resonanceAsymmetry]))
        cutoffFrequency.value = Float(AKRolandTB303Filter.defaultCutoffFrequency)
        resonance.value = Float(AKRolandTB303Filter.defaultResonance)
        distortion.value = Float(AKRolandTB303Filter.defaultDistortion)
        resonanceAsymmetry.value = Float(AKRolandTB303Filter.defaultResonanceAsymmetry)
    }

    public override var canProcessInPlace: Bool { return true }

}
