//
//  AKPitchShifter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Faust-based pitch shifter
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

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Pitch shift (in semitones)
    @objc open dynamic var shift: Double = 0 {
        willSet {
            if shift != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        shiftParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.shift = Float(newValue)
                }
            }
        }
    }
    /// Window size (in samples)
    @objc open dynamic var windowSize: Double = 1_024 {
        willSet {
            if windowSize != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        windowSizeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.windowSize = Float(newValue)
                }
            }
        }
    }
    /// Crossfade (in samples)
    @objc open dynamic var crossfade: Double = 512 {
        willSet {
            if crossfade != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        crossfadeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.crossfade = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        shift: Double = 0,
        windowSize: Double = 1_024,
        crossfade: Double = 512) {

        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
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

        internalAU?.shift = Float(shift)
        internalAU?.windowSize = Float(windowSize)
        internalAU?.crossfade = Float(crossfade)
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
