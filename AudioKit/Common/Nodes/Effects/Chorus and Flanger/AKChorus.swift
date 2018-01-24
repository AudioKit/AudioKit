//
//  AKChorus.swift
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

/// Stereo Chorus
///
open class AKChorus: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKChorusAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?
    
    // These must accord with #defines in SDModulatedDelayDSPKernel.hpp
    public static let MIN_FRACTION = 0.0
    public static let MAX_FRACTION = 1.0
    public static let MIN_FREQUENCY_HZ = 0.1
    public static let MAX_FREQUENCY_HZ = 10.0
    public static let DEFAULT_FREQUENCY_HZ = 1.0
    public static let MIN_FEEDBACK = 0.0
    public static let MAX_FEEDBACK = 0.25
    public static let DEFAULT_DRYWETMIX = 0.4

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?
    fileprivate var dryWetMixParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Modulation Frequency (Hz)
    @objc open dynamic var frequency: Double = MIN_FREQUENCY_HZ {
        willSet {
            if frequency == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && frequencyParameter != nil {
                    frequencyParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.frequency = Float(newValue)
        }
    }

    /// Modulation Depth (fraction)
    @objc open dynamic var depth: Double = MIN_FRACTION {
        willSet {
            if depth == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && depthParameter != nil {
                    depthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.depth = Float(newValue)
        }
    }
    
    /// Dry Wet Mix (fraction)
    @objc open dynamic var dryWetMix: Double = DEFAULT_DRYWETMIX {
        willSet {
            if dryWetMix == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && dryWetMixParameter != nil {
                    dryWetMixParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.dryWetMix = Float(newValue)
        }
    }
    
    /// Feedback (fraction)
    @objc open dynamic var feedback: Double = MIN_FRACTION {
        willSet {
            if feedback == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && feedbackParameter != nil {
                    feedbackParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.feedback = Float(newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - dryWetMix: fraction of wet signal in mix
    ///   - feedback: feedback fraction
    ///
    @objc public init(
        _ input: AKNode? = nil,
        frequency: Double = MIN_FREQUENCY_HZ,
        depth: Double = MIN_FRACTION,
        dryWetMix: Double = DEFAULT_DRYWETMIX,
        feedback: Double = MIN_FRACTION) {

        self.frequency = frequency
        self.depth = depth
        self.dryWetMix = dryWetMix
        self.feedback = feedback

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

        frequencyParameter = tree["frequency"]
        depthParameter = tree["depth"]
        dryWetMixParameter = tree["dryWetMix"]
        feedbackParameter = tree["feedback"]

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
        internalAU?.frequency = Float(frequency)
        internalAU?.depth = Float(depth)
        internalAU?.dryWetMix = Float(dryWetMix)
        internalAU?.feedback = Float(feedback)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        AKLog("start() \(isStopped)")
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        AKLog("stop() \(isPlaying)")
    }
}
