//
//  AKPitchShifter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Faust-based pitch shfiter
///
open class AKPitchShifter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPitchShifterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var shiftParameter: AUParameter?
    fileprivate var windowSizeParameter: AUParameter?
    fileprivate var crossfadeParameter: AUParameter?

    /// Lower and upper bounds for Shift
    public static let shiftRange = -24.0 ... 24.0

    /// Lower and upper bounds for Window Size
    public static let windowSizeRange = 0.0 ... 10_000.0

    /// Lower and upper bounds for Crossfade
    public static let crossfadeRange = 0.0 ... 10_000.0

    /// Initial value for Shift
    public static let defaultShift = 0.0

    /// Initial value for Window Size
    public static let defaultWindowSize = 1_024.0

    /// Initial value for Crossfade
    public static let defaultCrossfade = 512.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Pitch shift (in semitones)
    @objc open dynamic var shift: Double = defaultShift {
        willSet {
            if shift == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    shiftParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.shift, value: newValue)
        }
    }

    /// Window size (in samples)
    @objc open dynamic var windowSize: Double = defaultWindowSize {
        willSet {
            if windowSize == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    windowSizeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.windowSize, value: newValue)
        }
    }

    /// Crossfade (in samples)
    @objc open dynamic var crossfade: Double = defaultCrossfade {
        willSet {
            if crossfade == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    crossfadeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.crossfade, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - shift: Pitch shift (in semitones)
    ///   - windowSize: Window size (in samples)
    ///   - crossfade: Crossfade (in samples)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        shift: Double = defaultShift,
        windowSize: Double = defaultWindowSize,
        crossfade: Double = defaultCrossfade
        ) {

        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        shiftParameter = tree["shift"]
        windowSizeParameter = tree["windowSize"]
        crossfadeParameter = tree["crossfade"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.setParameterImmediately(.shift, value: shift)
        internalAU?.setParameterImmediately(.windowSize, value: windowSize)
        internalAU?.setParameterImmediately(.crossfade, value: crossfade)
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
