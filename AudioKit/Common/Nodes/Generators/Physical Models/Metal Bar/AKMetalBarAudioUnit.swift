// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKMetalBarAudioUnit: AKAudioUnitBase {

    private(set) var leftBoundaryCondition: AUParameter!

    private(set) var rightBoundaryCondition: AUParameter!

    private(set) var decayDuration: AUParameter!

    private(set) var scanSpeed: AUParameter!

    private(set) var position: AUParameter!

    private(set) var strikeVelocity: AUParameter!

    private(set) var strikeWidth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createMetalBarDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        leftBoundaryCondition = AUParameter(
            identifier: "leftBoundaryCondition",
            name: "Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free",
            address: AKMetalBarParameter.leftBoundaryCondition.rawValue,
            range: AKMetalBar.leftBoundaryConditionRange,
            unit: .hertz,
            flags: .default)
        rightBoundaryCondition = AUParameter(
            identifier: "rightBoundaryCondition",
            name: "Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free",
            address: AKMetalBarParameter.rightBoundaryCondition.rawValue,
            range: AKMetalBar.rightBoundaryConditionRange,
            unit: .hertz,
            flags: .default)
        decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "30db decay time (in seconds).",
            address: AKMetalBarParameter.decayDuration.rawValue,
            range: AKMetalBar.decayDurationRange,
            unit: .hertz,
            flags: .default)
        scanSpeed = AUParameter(
            identifier: "scanSpeed",
            name: "Speed of scanning the output location.",
            address: AKMetalBarParameter.scanSpeed.rawValue,
            range: AKMetalBar.scanSpeedRange,
            unit: .hertz,
            flags: .default)
        position = AUParameter(
            identifier: "position",
            name: "Position along bar that strike occurs.",
            address: AKMetalBarParameter.position.rawValue,
            range: AKMetalBar.positionRange,
            unit: .generic,
            flags: .default)
        strikeVelocity = AUParameter(
            identifier: "strikeVelocity",
            name: "Normalized strike velocity",
            address: AKMetalBarParameter.strikeVelocity.rawValue,
            range: AKMetalBar.strikeVelocityRange,
            unit: .generic,
            flags: .default)
        strikeWidth = AUParameter(
            identifier: "strikeWidth",
            name: "Spatial width of strike.",
            address: AKMetalBarParameter.strikeWidth.rawValue,
            range: AKMetalBar.strikeWidthRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [leftBoundaryCondition, rightBoundaryCondition, decayDuration, scanSpeed, position, strikeVelocity, strikeWidth])

        leftBoundaryCondition.value = AUValue(AKMetalBar.defaultLeftBoundaryCondition)
        rightBoundaryCondition.value = AUValue(AKMetalBar.defaultRightBoundaryCondition)
        decayDuration.value = AUValue(AKMetalBar.defaultDecayDuration)
        scanSpeed.value = AUValue(AKMetalBar.defaultScanSpeed)
        position.value = AUValue(AKMetalBar.defaultPosition)
        strikeVelocity.value = AUValue(AKMetalBar.defaultStrikeVelocity)
        strikeWidth.value = AUValue(AKMetalBar.defaultStrikeWidth)
    }
}
