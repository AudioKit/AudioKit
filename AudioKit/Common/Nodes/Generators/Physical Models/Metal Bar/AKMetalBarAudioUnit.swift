// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKMetalBarAudioUnit: AKAudioUnitBase {

    let leftBoundaryCondition = AUParameter(
        identifier: "leftBoundaryCondition",
        name: "Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free",
        address: AKMetalBarParameter.leftBoundaryCondition.rawValue,
        range: AKMetalBar.leftBoundaryConditionRange,
        unit: .hertz,
        flags: .default)

    let rightBoundaryCondition = AUParameter(
        identifier: "rightBoundaryCondition",
        name: "Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free",
        address: AKMetalBarParameter.rightBoundaryCondition.rawValue,
        range: AKMetalBar.rightBoundaryConditionRange,
        unit: .hertz,
        flags: .default)

    let decayDuration = AUParameter(
        identifier: "decayDuration",
        name: "30db decay time (in seconds).",
        address: AKMetalBarParameter.decayDuration.rawValue,
        range: AKMetalBar.decayDurationRange,
        unit: .hertz,
        flags: .default)

    let scanSpeed = AUParameter(
        identifier: "scanSpeed",
        name: "Speed of scanning the output location.",
        address: AKMetalBarParameter.scanSpeed.rawValue,
        range: AKMetalBar.scanSpeedRange,
        unit: .hertz,
        flags: .default)

    let position = AUParameter(
        identifier: "position",
        name: "Position along bar that strike occurs.",
        address: AKMetalBarParameter.position.rawValue,
        range: AKMetalBar.positionRange,
        unit: .generic,
        flags: .default)

    let strikeVelocity = AUParameter(
        identifier: "strikeVelocity",
        name: "Normalized strike velocity",
        address: AKMetalBarParameter.strikeVelocity.rawValue,
        range: AKMetalBar.strikeVelocityRange,
        unit: .generic,
        flags: .default)

    let strikeWidth = AUParameter(
        identifier: "strikeWidth",
        name: "Spatial width of strike.",
        address: AKMetalBarParameter.strikeWidth.rawValue,
        range: AKMetalBar.strikeWidthRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createMetalBarDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [leftBoundaryCondition,
                                                                  rightBoundaryCondition,
                                                                  decayDuration,
                                                                  scanSpeed,
                                                                  position,
                                                                  strikeVelocity,
                                                                  strikeWidth])
    }
}
