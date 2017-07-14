//
//  AKPhaser.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPhaserAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var notchMinimumFrequencyParameter: AUParameter?
    fileprivate var notchMaximumFrequencyParameter: AUParameter?
    fileprivate var notchWidthParameter: AUParameter?
    fileprivate var notchFrequencyParameter: AUParameter?
    fileprivate var vibratoModeParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?
    fileprivate var invertedParameter: AUParameter?
    fileprivate var lfoBPMParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Notch Minimum Frequency
    open dynamic var notchMinimumFrequency: Double = 100 {
        willSet {
            if notchMinimumFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        notchMinimumFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.notchMinimumFrequency = Float(newValue)
                }
            }
        }
    }

    /// Notch Maximum Frequency
    open dynamic var notchMaximumFrequency: Double = 800 {
        willSet {
            if notchMaximumFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        notchMaximumFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.notchMaximumFrequency = Float(newValue)
                }
            }
        }
    }

    /// Between 10 and 5000
    open dynamic var notchWidth: Double = 1_000 {
        willSet {
            if notchWidth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        notchWidthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.notchWidth = Float(newValue)
                }
            }
        }
    }

    /// Between 1.1 and 4
    open dynamic var notchFrequency: Double = 1.5 {
        willSet {
            if notchFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        notchFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.notchFrequency = Float(newValue)
                }
            }
        }
    }

    /// 1 or 0
    open dynamic var vibratoMode: Double = 1 {
        willSet {
            if vibratoMode != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        vibratoModeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.vibratoMode = Float(newValue)
                }
            }
        }
    }

    /// Between 0 and 1
    open dynamic var depth: Double = 1 {
        willSet {
            if depth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        depthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.depth = Float(newValue)
                }
            }
        }
    }

    /// Between 0 and 1
    open dynamic var feedback: Double = 0 {
        willSet {
            if feedback != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        feedbackParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.feedback = Float(newValue)
                }
            }
        }
    }

    /// 1 or 0
    open dynamic var inverted: Double = 0 {
        willSet {
            if inverted != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        invertedParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.inverted = Float(newValue)
                }
            }
        }
    }

    /// Between 24 and 360
    open dynamic var lfoBPM: Double = 30 {
        willSet {
            if lfoBPM != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        lfoBPMParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.lfoBPM = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this phaser node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - notchMinimumFrequency: Notch Minimum Frequency
    ///   - notchMaximumFrequency: Notch Maximum Frequency
    ///   - notchWidth: Between 10 and 5000
    ///   - notchFrequency: Between 1.1 and 4
    ///   - vibratoMode: 1 or 0
    ///   - depth: Between 0 and 1
    ///   - feedback: Between 0 and 1
    ///   - inverted: 1 or 0
    ///   - lfoBPM: Between 24 and 360
    ///
    public init(
        _ input: AKNode?,
        notchMinimumFrequency: Double = 100,
        notchMaximumFrequency: Double = 800,
        notchWidth: Double = 1_000,
        notchFrequency: Double = 1.5,
        vibratoMode: Double = 1,
        depth: Double = 1,
        feedback: Double = 0,
        inverted: Double = 0,
        lfoBPM: Double = 30) {

        self.notchMinimumFrequency = notchMinimumFrequency
        self.notchMaximumFrequency = notchMaximumFrequency
        self.notchWidth = notchWidth
        self.notchFrequency = notchFrequency
        self.vibratoMode = vibratoMode
        self.depth = depth
        self.feedback = feedback
        self.inverted = inverted
        self.lfoBPM = lfoBPM

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        notchMinimumFrequencyParameter = tree["notchMinimumFrequency"]
        notchMaximumFrequencyParameter = tree["notchMaximumFrequency"]
        notchWidthParameter = tree["notchWidth"]
        notchFrequencyParameter = tree["notchFrequency"]
        vibratoModeParameter = tree["vibratoMode"]
        depthParameter = tree["depth"]
        feedbackParameter = tree["feedback"]
        invertedParameter = tree["inverted"]
        lfoBPMParameter = tree["lfoBPM"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.notchMinimumFrequency = Float(notchMinimumFrequency)
        internalAU?.notchMaximumFrequency = Float(notchMaximumFrequency)
        internalAU?.notchWidth = Float(notchWidth)
        internalAU?.notchFrequency = Float(notchFrequency)
        internalAU?.vibratoMode = Float(vibratoMode)
        internalAU?.depth = Float(depth)
        internalAU?.feedback = Float(feedback)
        internalAU?.inverted = Float(inverted)
        internalAU?.lfoBPM = Float(lfoBPM)
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
