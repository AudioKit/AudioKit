//
//  AKAutoWah.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

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
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Wah Amount
    open dynamic var wah: Double = 0.0 {
        willSet {
            if wah != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    wahParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.wah = Float(newValue)
                }
            }
        }
    }
    /// Dry/Wet Mix
    open dynamic var mix: Double = 1.0 {
        willSet {
            if mix != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    mixParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.mix = Float(newValue)
                }
            }
        }
    }
    /// Overall level
    open dynamic var amplitude: Double = 0.1 {
        willSet {
            if amplitude != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.amplitude = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        wahParameter = tree["wah"]
        mixParameter = tree["mix"]
        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.wahParameter?.address {
                    self?.wah = Double(value)
                } else if address == self?.mixParameter?.address {
                    self?.mix = Double(value)
                } else if address == self?.amplitudeParameter?.address {
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
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
