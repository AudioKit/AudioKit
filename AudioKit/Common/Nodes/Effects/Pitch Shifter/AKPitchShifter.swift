//
//  AKPitchShifter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Faust-based pitch shfiter
///
open class AKPitchShifter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPitchShifterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var shiftParameter: AUParameter?
    fileprivate var windowSizeParameter: AUParameter?
    fileprivate var crossfadeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Pitch shift (in semitones)
    open dynamic var shift: Double = 0 {
        willSet {
            if shift != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    shiftParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.shift = Float(newValue)
                }
            }
        }
    }
    /// Window size (in samples)
    open dynamic var windowSize: Double = 1_024 {
        willSet {
            if windowSize != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    windowSizeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.windowSize = Float(newValue)
                }
            }
        }
    }
    /// Crossfade (in samples)
    open dynamic var crossfade: Double = 512 {
        willSet {
            if crossfade != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    crossfadeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.crossfade = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - shift: Pitch shift (in semitones)
    ///   - windowSize: Window size (in samples)
    ///   - crossfade: Crossfade (in samples)
    ///
    public init(
        _ input: AKNode,
        shift: Double = 0,
        windowSize: Double = 1_024,
        crossfade: Double = 512) {

        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade

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

        shiftParameter = tree["shift"]
        windowSizeParameter = tree["windowSize"]
        crossfadeParameter = tree["crossfade"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.shiftParameter?.address {
                    self?.shift = Double(value)
                } else if address == self?.windowSizeParameter?.address {
                    self?.windowSize = Double(value)
                } else if address == self?.crossfadeParameter?.address {
                    self?.crossfade = Double(value)
                }
            }
        })

        internalAU?.shift = Float(shift)
        internalAU?.windowSize = Float(windowSize)
        internalAU?.crossfade = Float(crossfade)
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
