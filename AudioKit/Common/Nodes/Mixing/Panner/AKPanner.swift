//
//  AKPanner.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo Panner
///
open class AKPanner: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPannerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "pan2")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var panParameter: AUParameter?

    /// Lower and upper bounds for Pan
    public static let panRange = -1.0 ... 1.0

    /// Initial value for Pan
    public static let defaultPan = 0.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    @objc open dynamic var pan: Double = defaultPan {
        willSet {
            guard pan != newValue else { return }
            if internalAU?.isSetUp == true {
                panParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.pan, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        pan: Double = defaultPan
        ) {

        self.pan = pan

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

        panParameter = tree["pan"]

        internalAU?.setParameterImmediately(.pan, value: pan)
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
