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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKMetalBarParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createMetalBarDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let leftBoundaryCondition = AUParameterTree.createParameter(
            withIdentifier: "leftBoundaryCondition",
            name: "Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free",
            address: AUParameterAddress(0),
            min: Float(AKMetalBar.leftBoundaryConditionRange.lowerBound),
            max: Float(AKMetalBar.leftBoundaryConditionRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let rightBoundaryCondition = AUParameterTree.createParameter(
            withIdentifier: "rightBoundaryCondition",
            name: "Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free",
            address: AUParameterAddress(1),
            min: Float(AKMetalBar.rightBoundaryConditionRange.lowerBound),
            max: Float(AKMetalBar.rightBoundaryConditionRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let decayDuration = AUParameterTree.createParameter(
            withIdentifier: "decayDuration",
            name: "30db decay time (in seconds).",
            address: AUParameterAddress(2),
            min: Float(AKMetalBar.decayDurationRange.lowerBound),
            max: Float(AKMetalBar.decayDurationRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let scanSpeed = AUParameterTree.createParameter(
            withIdentifier: "scanSpeed",
            name: "Speed of scanning the output location.",
            address: AUParameterAddress(3),
            min: Float(AKMetalBar.scanSpeedRange.lowerBound),
            max: Float(AKMetalBar.scanSpeedRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let position = AUParameterTree.createParameter(
            withIdentifier: "position",
            name: "Position along bar that strike occurs.",
            address: AUParameterAddress(4),
            min: Float(AKMetalBar.positionRange.lowerBound),
            max: Float(AKMetalBar.positionRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let strikeVelocity = AUParameterTree.createParameter(
            withIdentifier: "strikeVelocity",
            name: "Normalized strike velocity",
            address: AUParameterAddress(5),
            min: Float(AKMetalBar.strikeVelocityRange.lowerBound),
            max: Float(AKMetalBar.strikeVelocityRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let strikeWidth = AUParameterTree.createParameter(
            withIdentifier: "strikeWidth",
            name: "Spatial width of strike.",
            address: AUParameterAddress(6),
            min: Float(AKMetalBar.strikeWidthRange.lowerBound),
            max: Float(AKMetalBar.strikeWidthRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [leftBoundaryCondition, rightBoundaryCondition, decayDuration, scanSpeed, position, strikeVelocity, strikeWidth]))
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
