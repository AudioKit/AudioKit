//
//  AKFormantFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
/// - Parameters:
///   - input: Input node to process
///   - x: x Position
///   - y: y Position
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFormantFilterAudioUnit
    static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?

    fileprivate var xParameter: AUParameter?
    fileprivate var yParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Center frequency.
    open var x: Double = 0 {
        willSet {
            if x != newValue {
                if internalAU!.isSetUp() {
                    xParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.x = Float(newValue)
                }
            }
        }
    }
    /// Impulse response attack time (in seconds).
    open var y: Double = 0 {
        willSet {
            if y != newValue {
                if internalAU!.isSetUp() {
                    yParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.y = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
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
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        xParameter = tree["x"]
        yParameter  = tree["y"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.xParameter!.address {
                    self.x = Double(value)
                } else if address == self.yParameter!.address {
                    self.y = Double(value)
                }
            }
        })

        internalAU?.x = Float(x)
        internalAU?.y = Float(y)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
