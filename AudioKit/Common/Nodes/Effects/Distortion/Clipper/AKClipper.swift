//
//  AKClipper.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
open class AKClipper: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKClipperAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "clip")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var limitParameter: AUParameter?

    /// Lower and upper bounds for Limit
    public static let limitRange = 0.0 ... 1.0

    /// Initial value for Limit
    public static let defaultLimit = 1.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Threshold / limiting value.
    @objc open dynamic var limit: Double = defaultLimit {
        willSet {
            guard limit != newValue else { return }
            if internalAU?.isSetUp == true {
                limitParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.limit, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        limit: Double = defaultLimit
        ) {

        self.limit = limit

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

        limitParameter = tree["limit"]

        internalAU?.setParameterImmediately(.limit, value: limit)
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
