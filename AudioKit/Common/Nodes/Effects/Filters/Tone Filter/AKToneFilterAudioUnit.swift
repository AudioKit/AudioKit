// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKToneFilterAudioUnit: AKAudioUnitBase {

    let halfPowerPoint = AUParameter(
        identifier: "halfPowerPoint",
        name: "Half-Power Point (Hz)",
        address: AKToneFilterParameter.halfPowerPoint.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createToneFilterDSP()
    }
}
