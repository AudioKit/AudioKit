//
//  AKMetalBarAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMetalBarAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKMetalBarParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKMetalBarParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var leftBoundaryCondition: Double = AKMetalBar.defaultLeftBoundaryCondition {
        didSet { setParameter(.leftBoundaryCondition, value: leftBoundaryCondition) }
    }

    var rightBoundaryCondition: Double = AKMetalBar.defaultRightBoundaryCondition {
        didSet { setParameter(.rightBoundaryCondition, value: rightBoundaryCondition) }
    }

    var decayDuration: Double = AKMetalBar.defaultDecayDuration {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var scanSpeed: Double = AKMetalBar.defaultScanSpeed {
        didSet { setParameter(.scanSpeed, value: scanSpeed) }
    }

    var position: Double = AKMetalBar.defaultPosition {
        didSet { setParameter(.position, value: position) }
    }

    var strikeVelocity: Double = AKMetalBar.defaultStrikeVelocity {
        didSet { setParameter(.strikeVelocity, value: strikeVelocity) }
    }

    var strikeWidth: Double = AKMetalBar.defaultStrikeWidth {
        didSet { setParameter(.strikeWidth, value: strikeWidth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createMetalBarDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
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

        setParameterTree(AUParameterTree(children: [leftBoundaryCondition, rightBoundaryCondition, decayDuration, scanSpeed, position, strikeVelocity, strikeWidth]))
        leftBoundaryCondition.value = Float(AKMetalBar.defaultLeftBoundaryCondition)
        rightBoundaryCondition.value = Float(AKMetalBar.defaultRightBoundaryCondition)
        decayDuration.value = Float(AKMetalBar.defaultDecayDuration)
        scanSpeed.value = Float(AKMetalBar.defaultScanSpeed)
        position.value = Float(AKMetalBar.defaultPosition)
        strikeVelocity.value = Float(AKMetalBar.defaultStrikeVelocity)
        strikeWidth.value = Float(AKMetalBar.defaultStrikeWidth)
    }

    public override var canProcessInPlace: Bool { return true }

}
