//
//  AKVocalTract.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
/// - parameter frequency: Glottal frequency.
/// - parameter tonguePosition: Tongue position (0-1)
/// - parameter tongueDiameter: Tongue diameter (0-1)
/// - parameter tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
/// - parameter nasality: Sets the velum size. Larger values of this creates more nasally sounds.
///
public class AKVocalTract: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKVocalTractAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var tonguePositionParameter: AUParameter?
    fileprivate var tongueDiameterParameter: AUParameter?
    fileprivate var tensenessParameter: AUParameter?
    fileprivate var nasalityParameter: AUParameter?


    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Glottal frequency.
    open dynamic var frequency: Double = 160.0 {
        willSet {
            if frequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        frequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }

    /// Tongue position (0-1)
    open dynamic var tonguePosition: Double = 0.5 {
        willSet {
            if tonguePosition != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        tonguePositionParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.tonguePosition = Float(newValue)
                }
            }
        }
    }

    /// Tongue diameter (0-1)
    open dynamic var tongueDiameter: Double = 1.0 {
        willSet {
            if tongueDiameter != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        tongueDiameterParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.tongueDiameter = Float(newValue)
                }
            }
        }
    }

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    open dynamic var tenseness: Double = 0.6 {
        willSet {
            if tenseness != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        tensenessParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.tenseness = Float(newValue)
                }
            }
        }
    }

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    open dynamic var nasality: Double = 0.0 {
        willSet {
            if nasality != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        nasalityParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.nasality = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this vocal tract node
    ///
    /// - parameter frequency: Glottal frequency.
    /// - parameter tonguePosition: Tongue position (0-1)
    /// - parameter tongueDiameter: Tongue diameter (0-1)
    /// - parameter tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    /// - parameter nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    public init(
        frequency: Double = 160.0,
        tonguePosition: Double = 0.5,
        tongueDiameter: Double = 1.0,
        tenseness: Double = 0.6,
        nasality: Double = 0.0) {


        self.frequency = frequency
        self.tonguePosition = tonguePosition
        self.tongueDiameter = tongueDiameter
        self.tenseness = tenseness
        self.nasality = nasality

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter      = tree.value(forKey: "frequency")      as? AUParameter
        tonguePositionParameter = tree.value(forKey: "tonguePosition") as? AUParameter
        tongueDiameterParameter = tree.value(forKey: "tongueDiameter") as? AUParameter
        tensenessParameter      = tree.value(forKey: "tenseness")      as? AUParameter
        nasalityParameter       = tree.value(forKey: "nasality")       as? AUParameter

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.frequencyParameter?.address {
                    self?.frequency = Double(value)
                } else if address == self?.tonguePositionParameter?.address {
                    self?.tonguePosition = Double(value)
                } else if address == self?.tongueDiameterParameter?.address {
                    self?.tongueDiameter = Double(value)
                } else if address == self?.tensenessParameter?.address {
                    self?.tenseness = Double(value)
                } else if address == self?.nasalityParameter?.address {
                    self?.nasality = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.tonguePosition = Float(tonguePosition)
        internalAU?.tongueDiameter = Float(tongueDiameter)
        internalAU?.tenseness = Float(tenseness)
        internalAU?.nasality = Float(nasality)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
