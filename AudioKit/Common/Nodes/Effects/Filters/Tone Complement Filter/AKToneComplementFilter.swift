//
//  AKToneComplementFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A complement to the AKLowPassFilter.
///
open class AKToneComplementFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKToneComplementFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "aton")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Lower and upper bounds for Half Power Point
    public static let halfPowerPointRange = 12.0 ... 20_000.0

    /// Initial value for Half Power Point
    public static let defaultHalfPowerPoint = 1_000.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    @objc open dynamic var halfPowerPoint: Double = defaultHalfPowerPoint {
        willSet {
            guard halfPowerPoint != newValue else { return }
            if internalAU?.isSetUp == true {
                halfPowerPointParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.halfPowerPoint, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        halfPowerPoint: Double = defaultHalfPowerPoint
        ) {

        self.halfPowerPoint = halfPowerPoint

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        halfPowerPointParameter = tree["halfPowerPoint"]

        internalAU?.setParameterImmediately(.halfPowerPoint, value: halfPowerPoint)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
