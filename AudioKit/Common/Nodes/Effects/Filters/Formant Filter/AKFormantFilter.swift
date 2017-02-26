//
//  AKFormantFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFormantFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var xParameter: AUParameter?
    fileprivate var yParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Center frequency.
    open dynamic var x: Double = 0 {
        willSet {
            if x != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        xParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.x = Float(newValue)
                }
            }
        }
    }
    /// Impulse response attack time (in seconds).
    open dynamic var y: Double = 0 {
        willSet {
            if y != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        yParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.y = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - attackDuration: Impulse response attack time (in seconds).
    ///   - decayDuration: Impulse reponse decay time (in seconds)
    ///
    public init(
        _ input: AKNode,
        x: Double = 0,
        y: Double = 0) {

        self.x = x
        self.y = y

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        xParameter = tree["x"]
        yParameter = tree["y"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.xParameter?.address {
                    self?.x = Double(value)
                } else if address == self?.yParameter?.address {
                    self?.y = Double(value)
                }
            }
        })

        internalAU?.x = Float(x)
        internalAU?.y = Float(y)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
