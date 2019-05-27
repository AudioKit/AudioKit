//
//  AKRhinoGuitarProcessor.swift
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Guitar head and cab simulator.
///
open class AKRhinoGuitarProcessor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKRhinoGuitarProcessorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "dlrh")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var preGainParameter: AUParameter?
    fileprivate var postGainParameter: AUParameter?
    fileprivate var lowGainParameter: AUParameter?
    fileprivate var midGainParameter: AUParameter?
    fileprivate var highGainParameter: AUParameter?
    fileprivate var distortionParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = rampDuration
        }
    }

    /// Determines the amount of gain applied to the signal before processing.
    @objc open dynamic var preGain: Double = 5.0 {
        willSet {
            guard preGain != newValue else { return }
            if internalAU?.isSetUp == true {
                preGainParameter?.value = AUValue(newValue)
            } else {
                internalAU?.preGain = AUValue(newValue)
            }
        }
    }

    /// Gain applied after processing.
    @objc open dynamic var postGain: Double = 0.7 {
        willSet {
            guard postGain != newValue else { return }
            if internalAU?.isSetUp == true {
                postGainParameter?.value = AUValue(newValue)
            } else {
                internalAU?.postGain = AUValue(newValue)
            }
        }
    }

    /// Amount of Low frequencies.
    @objc open dynamic var lowGain: Double = 0.0 {
        willSet {
            guard lowGain != newValue else { return }
            if internalAU?.isSetUp == true {
                lowGainParameter?.value = AUValue(newValue)
            } else {
                internalAU?.lowGain = AUValue(newValue)
            }
        }
    }

    /// Amount of Middle frequencies.
    @objc open dynamic var midGain: Double = 0.0 {
        willSet {
            guard midGain != newValue else { return }
            if internalAU?.isSetUp == true {
                midGainParameter?.value = AUValue(newValue)
            } else {
                internalAU?.midGain = AUValue(newValue)
            }
        }
    }

    /// Amount of High frequencies.
    @objc open dynamic var highGain: Double = 0.0 {
        willSet {
            guard highGain != newValue else { return }
            if internalAU?.isSetUp == true {
                highGainParameter?.value = AUValue(newValue)
            } else {
                internalAU?.highGain = AUValue(newValue)
            }
        }
    }

    /// Distortion Amount
    @objc open dynamic var distortion: Double = 1.0 {
        willSet {
            guard distortion != newValue else { return }
            if internalAU?.isSetUp == true {
                distortionParameter?.value = AUValue(newValue)
            } else {
                internalAU?.distortion = AUValue(newValue)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this Rhino head and cab simulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - preGain: Determines the amount of gain applied to the signal before processing.
    ///   - postGain: Gain applied after processing.
    ///   - lowGain: Amount of Low frequencies.
    ///   - midGain: Amount of Middle frequencies.
    ///   - highGain: Amount of High frequencies.
    ///   - distortion: Distortion Amount
    ///
    @objc public init(
        _ input: AKNode? = nil,
        preGain: Double = 5.0,
        postGain: Double = 0.7,
        lowGain: Double = 0.0,
        midGain: Double = 0.0,
        highGain: Double = 0.0,
        distortion: Double = 1.0) {

        self.preGain = preGain
        self.postGain = postGain
        self.lowGain = lowGain
        self.midGain = midGain
        self.highGain = highGain
        self.distortion = distortion

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

        preGainParameter = tree["preGain"]
        postGainParameter = tree["postGain"]
        lowGainParameter = tree["lowGain"]
        midGainParameter = tree["midGain"]
        highGainParameter = tree["highGain"]
        distortionParameter = tree["distortion"]

        internalAU?.preGain = Float(preGain)
        internalAU?.postGain = Float(postGain)
        internalAU?.lowGain = Float(lowGain)
        internalAU?.midGain = Float(midGain)
        internalAU?.highGain = Float(highGain)
        internalAU?.distortion = Float(distortion)
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
