//
//  AKVocalTract.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
open class AKVocalTract: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKVocalTractAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var tonguePositionParameter: AUParameter?
    fileprivate var tongueDiameterParameter: AUParameter?
    fileprivate var tensenessParameter: AUParameter?
    fileprivate var nasalityParameter: AUParameter?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 0.0 ... 22050.0

    /// Lower and upper bounds for Tongue Position
    public static let tonguePositionRange = 0.0 ... 1.0

    /// Lower and upper bounds for Tongue Diameter
    public static let tongueDiameterRange = 0.0 ... 1.0

    /// Lower and upper bounds for Tenseness
    public static let tensenessRange = 0.0 ... 1.0

    /// Lower and upper bounds for Nasality
    public static let nasalityRange = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency = 160.0

    /// Initial value for Tongue Position
    public static let defaultTonguePosition = 0.5

    /// Initial value for Tongue Diameter
    public static let defaultTongueDiameter = 1.0

    /// Initial value for Tenseness
    public static let defaultTenseness = 0.6

    /// Initial value for Nasality
    public static let defaultNasality = 0.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Glottal frequency.
    @objc open dynamic var frequency: Double = defaultFrequency {
        willSet {
            guard frequency != newValue else { return }
            if internalAU?.isSetUp == true {
                frequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Tongue position (0-1)
    @objc open dynamic var tonguePosition: Double = defaultTonguePosition {
        willSet {
            guard tonguePosition != newValue else { return }
            if internalAU?.isSetUp == true {
                tonguePositionParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.tonguePosition, value: newValue)
        }
    }

    /// Tongue diameter (0-1)
    @objc open dynamic var tongueDiameter: Double = defaultTongueDiameter {
        willSet {
            guard tongueDiameter != newValue else { return }
            if internalAU?.isSetUp == true {
                tongueDiameterParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.tongueDiameter, value: newValue)
        }
    }

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    @objc open dynamic var tenseness: Double = defaultTenseness {
        willSet {
            guard tenseness != newValue else { return }
            if internalAU?.isSetUp == true {
                tensenessParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.tenseness, value: newValue)
        }
    }

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    @objc open dynamic var nasality: Double = defaultNasality {
        willSet {
            guard nasality != newValue else { return }
            if internalAU?.isSetUp == true {
                nasalityParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.nasality, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this vocal tract node
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    @objc public init(
        frequency: Double = defaultFrequency,
        tonguePosition: Double = defaultTonguePosition,
        tongueDiameter: Double = defaultTongueDiameter,
        tenseness: Double = defaultTenseness,
        nasality: Double = defaultNasality
    ) {

        self.frequency = frequency
        self.tonguePosition = tonguePosition
        self.tongueDiameter = tongueDiameter
        self.tenseness = tenseness
        self.nasality = nasality

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
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        tonguePositionParameter = tree["tonguePosition"]
        tongueDiameterParameter = tree["tongueDiameter"]
        tensenessParameter = tree["tenseness"]
        nasalityParameter = tree["nasality"]

        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.tonguePosition, value: tonguePosition)
        internalAU?.setParameterImmediately(.tongueDiameter, value: tongueDiameter)
        internalAU?.setParameterImmediately(.tenseness, value: tenseness)
        internalAU?.setParameterImmediately(.nasality, value: nasality)
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
