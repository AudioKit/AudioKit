// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKOscillatorAudioUnit: AKAudioUnitBase {

    public override func getParameterDefs() -> [AKNodeParameterDef] {
        return [AKOscillator.frequencyDef,
                AKOscillator.amplitudeDef,
                AKOscillator.detuningOffsetDef,
                AKOscillator.detuningMultiplierDef]
    }

    public override func createDSP() -> AKDSPRef {
        return createOscillatorDSP()
    }

}
