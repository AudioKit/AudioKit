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
    public static let MIN_MODFREQ_HZ = 0.1
    public static let MAX_MODFREQ_HZ = 10.0
    public static let DEFAULT_MODFREQ_HZ = 1.0
    public static let MIN_FEEDBACK = 0.0
    public static let MAX_FEEDBACK = 0.25
    public static let DEFAULT_WETFRACTION = 0.4

    fileprivate var modFreqParameter: AUParameter?
    fileprivate var modDepthParameter: AUParameter?
    fileprivate var wetFractionParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Mod Frequency (Hz)
    @objc open dynamic var modFreq: Double = MIN_MODFREQ_HZ {
        willSet {
            if modFreq == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && modFreqParameter != nil {
                    modFreqParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.modFreq = Float(newValue)
        }
    }

    /// Mod Depth (fraction)
    @objc open dynamic var modDepth: Double = MIN_FRACTION {
        willSet {
            if modDepth == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && modDepthParameter != nil {
                    modDepthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.modDepth = Float(newValue)
        }
    }
    
    /// Wet (fraction)
    @objc open dynamic var wetFraction: Double = DEFAULT_WETFRACTION {
        willSet {
            if wetFraction == newValue {
                return
            }
            
            if internalAU?.isSetUp ?? false {
                if token != nil && wetFractionParameter != nil {
                    wetFractionParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            
            internalAU?.wetFraction = Float(newValue)
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
    ///   - modFreq: modulation frequency Hz
    ///   - modDepth: depth of modulation (fraction)
    ///   - wetFraction: fraction of wet signal in mix
    ///   - feedback: feedback fraction
    ///
    @objc public init(
        _ input: AKNode? = nil,
        modFreq: Double = MIN_MODFREQ_HZ,
        modDepth: Double = MIN_FRACTION,
        wetFraction: Double = DEFAULT_WETFRACTION,
        feedback: Double = MIN_FRACTION) {

        self.modFreq = modFreq
        self.modDepth = modDepth
        self.wetFraction = wetFraction
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

        modFreqParameter = tree["modFreq"]
        modDepthParameter = tree["modDepth"]
        wetFractionParameter = tree["wetFraction"]
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
        internalAU?.modFreq = Float(modFreq)
        internalAU?.modDepth = Float(modDepth)
        internalAU?.wetFraction = Float(wetFraction)
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
