//
//  AKRhinoGuitarProcessor.swift
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
//

/// Guitar head and cab simulator.
///
open class AKRhinoGuitarProcessor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKRhinoGuitarProcessorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "dlrh")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var preGainParameter: AUParameter?
    fileprivate var postGainParameter: AUParameter?
    fileprivate var lowGainParameter: AUParameter?
    fileprivate var midGainParameter: AUParameter?
    fileprivate var highGainParameter: AUParameter?
    //fileprivate var distTypeParameter: AUParameter?
    fileprivate var distAmountParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Determines the amount of gain applied to the signal before processing.
    @objc open dynamic var preGain: Double = 5.0 {
        willSet {
            if preGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        preGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.preGain = Float(newValue)
                }
            }
        }
    }

    /// Gain applied after processing.
    @objc open dynamic var postGain: Double = 0.7 {
        willSet {
            if postGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        postGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.postGain = Float(newValue)
                }
            }
        }
    }

    /// Amount of Low frequencies.
    @objc open dynamic var lowGain: Double = 0.0 {
        willSet {
            if lowGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lowGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lowGain = Float(newValue)
                }
            }
        }
    }

    /// Amount of Middle frequencies.
    @objc open dynamic var midGain: Double = 0.0 {
        willSet {
            if midGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        midGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.midGain = Float(newValue)
                }
            }
        }
    }

    /// Amount of High frequencies.
    @objc open dynamic var highGain: Double = 0.0 {
        willSet {
            if highGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        highGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.highGain = Float(newValue)
                }
            }
        }
    }

    /// Distortion Type
    //    open dynamic var distType: Double = 1 {
    //        willSet {
    //            if distType != newValue {
    //                if internalAU?.isSetUp() ?? false {
    //                    if let existingToken = token {
    //                        distTypeParameter?.setValue(Float(newValue), originator: existingToken)
    //                    }
    //                } else {
    //                    internalAU?.distType = Float(newValue)
    //                }
    //            }
    //        }
    //    }

    /// Distortion Amount
    @objc open dynamic var distAmount: Double = 1.0 {
        willSet {
            if distAmount != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        distAmountParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.distAmount = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
    ///   - distType: Distortion Type
    ///   - distAmount: Distortion Amount
    ///
    @objc public init(
        _ input: AKNode? = nil,
        preGain: Double = 5.0,
        postGain: Double = 0.7,
        lowGain: Double = 0.0,
        midGain: Double = 0.0,
        highGain: Double = 0.0,
        distType: Double = 1,
        distAmount: Double = 1.0) {

        self.preGain = preGain
        self.postGain = postGain
        self.lowGain = lowGain
        self.midGain = midGain
        self.highGain = highGain
        //self.distType = distType
        self.distAmount = distAmount

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

        preGainParameter = tree["preGain"]
        postGainParameter = tree["postGain"]
        lowGainParameter = tree["lowGain"]
        midGainParameter = tree["midGain"]
        highGainParameter = tree["highGain"]
        //distTypeParameter = tree["distType"]
        distAmountParameter = tree["distAmount"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.preGainParameter?.address {
                    self?.preGain = Double(value)
                } else if address == self?.postGainParameter?.address {
                    self?.postGain = Double(value)
                } else if address == self?.lowGainParameter?.address {
                    self?.lowGain = Double(value)
                } else if address == self?.midGainParameter?.address {
                    self?.midGain = Double(value)
                } else if address == self?.highGainParameter?.address {
                    self?.highGain = Double(value)
                } else if address == self?.distAmountParameter?.address {
                    self?.distAmount = Double(value)
                }
            }
        })

        internalAU?.preGain = Float(preGain)
        internalAU?.postGain = Float(postGain)
        internalAU?.lowGain = Float(lowGain)
        internalAU?.midGain = Float(midGain)
        internalAU?.highGain = Float(highGain)
        internalAU?.distType = Float(distType)
        internalAU?.distAmount = Float(distAmount)
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
