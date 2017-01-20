//
//  AKAutoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// An automatic wah effect, ported from Guitarix via Faust.
///
open class AKAutoWah: AKNode, AKToggleable, AKComponent {
  public typealias AKAudioUnitType = AKAutoWahAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var wahParameter: AUParameter?
    fileprivate var mixParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Wah Amount
    open var wah: Double = 0.0 {
        willSet {
            if wah != newValue {
                if internalAU!.isSetUp() {
                    wahParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.wah = Float(newValue)
                }
            }
        }
    }
    /// Dry/Wet Mix
    open var mix: Double = 1.0 {
        willSet {
            if mix != newValue {
                if internalAU!.isSetUp() {
                    mixParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.mix = Float(newValue)
                }
            }
        }
    }
    /// Overall level
    open var amplitude: Double = 0.1 {
        willSet {
            if amplitude != newValue {
                if internalAU!.isSetUp() {
                    amplitudeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.amplitude = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this autoWah node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - wah: Wah Amount
    ///   - mix: Dry/Wet Mix
    ///   - amplitude: Overall level
    ///
    public init(
        _ input: AKNode,
        wah: Double = 0.0,
        mix: Double = 1.0,
        amplitude: Double = 0.1) {

        self.wah = wah
        self.mix = mix
        self.amplitude = amplitude

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else { return }

        wahParameter       = tree["wah"]
        mixParameter       = tree["mix"]
        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self]
            address, value in

            DispatchQueue.main.async {
                if address == self?.wahParameter!.address {
                    self?.wah = Double(value)
                } else if address == self?.mixParameter!.address {
                    self?.mix = Double(value)
                } else if address == self?.amplitudeParameter!.address {
                    self?.amplitude = Double(value)
                }
            }
        })

        internalAU?.wah = Float(wah)
        internalAU?.mix = Float(mix)
        internalAU?.amplitude = Float(amplitude)
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
