//
//  AKShaker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public enum AKShakerType: UInt8 {
    
    /// Maraca
    case maraca = 0
    
    /// Cabasa
    case cabasa = 1
    
    /// Sekere
    case sekere = 2
    
    /// Tambourine
    case tambourine = 3
    
    /// Sleigh Bells
    case sleighBells = 4
    
    /// Bamboo Chimes
    case bambooChimes = 5
    
    /// Using sand paper
    case sandPaper = 6
    
    /// Soda Can
    case sodaCan = 7
    
    /// Sticks falling
    case sticks = 8
    
    /// Crunching sound
    case crunch = 9
    
    /// Big rocks hitting each other
    case bigRocks = 10
    
    /// Little rocks hitting each other
    case littleRocks = 11
    
    /// NeXT Mug
    case nextMug = 12
    
    /// A penny rattling around a mug
    case pennyInMug = 13
    
    /// A nickle rattling around a mug
    case nickleInMug = 14
    
    /// A dime rattling around a mug
    case dimeInMug = 15
    
    /// A quarter rattling around a mug
    case quarterInMug = 16
    
    /// A Franc rattling around a mug
    case francInMug = 17
    
    /// A Peso rattling around a mug
    case pesoInMug = 18
    
    /// Guiro
    case guiro = 19
    
    /// Wrench
    case wrench = 20
    
    /// Water Droplets
    case waterDrops = 21
    
    /// Tuned Bamboo Chimes
    case tunedBambooChimes = 22
}

/// STK Shaker
///
open class AKShaker: AKNode, AKToggleable, AKComponent {
    /// Four letter unique description of the node
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
