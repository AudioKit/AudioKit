//
//  AKShaker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//



public enum AKShakerType: UInt8 {
    case maraca = 0
    case cabasa = 1
    case sekere = 2
    case tambourine = 3
    case sleighBells = 4
    case bambooChimes = 5
    case sandPaper = 6
    case sodaCan = 7
    case sticks = 8
    case crunch = 9
    case bigRocks = 10
    case littleRocks = 11
    case nextMug = 12
    case pennyInMug = 13
    case nickleInMug = 14
    case dimeInMug = 15
    case quarterInMug = 16
    case francInMug = 17
    case pesoInMug = 18
    case guiro = 19
    case wrench = 20
    case waterDrops = 21
    case tunedBambooChimes = 22
}

/// STK Shaker
///
open class AKShaker: AKNode, AKToggleable, AKComponent {
    public static let ComponentDescription = AudioComponentDescription(generator: "shak")
    public typealias AKAudioUnitType = AKShakerAudioUnit
    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }
    
    open var type: AKShakerType = .maraca {
        willSet {
            if type != newValue {
                internalAU?.type = type.rawValue
            }
        }
    }

    /// Amplitude
    open dynamic var amplitude: Double = 0.5 {
        willSet {
            if amplitude != newValue {
                if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize the mandolin with defaults
    override convenience init() {
        self.init(type: .maraca)
    }

    /// Initialize the STK Shaker model
    ///
    /// - Parameters:
    ///   - amplitude: Overall level
    ///
    public init(type: AKShakerType = .maraca, amplitude: Double = 0.5) {

        self.type = type
        self.amplitude = amplitude

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.amplitudeParameter?.address {
                    self?.amplitude = Double(value)
                }
            }
        })
        internalAU?.type = type.rawValue
        internalAU?.amplitude = Float(amplitude)
    }

    /// Trigger the sound with an optional set of parameters
    /// - amplitude amplitude: Volume
    ///
    open func trigger(amplitude: Double = 0.5) {
        self.amplitude = amplitude
        internalAU?.start()
        internalAU?.triggerType(type.rawValue, amplitude: Float(amplitude))
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
