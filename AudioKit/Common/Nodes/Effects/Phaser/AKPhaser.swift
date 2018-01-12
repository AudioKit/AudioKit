//
//  AKPhaser.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput {
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
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Notch Minimum Frequency
    @objc open dynamic var notchMinimumFrequency: Double = 100 {
        willSet {
            if notchMinimumFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    notchMinimumFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.notchMinimumFrequency, value: newValue)
        }
    }

    /// Notch Maximum Frequency
    @objc open dynamic var notchMaximumFrequency: Double = 800 {
        willSet {
            if notchMaximumFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    notchMaximumFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.notchMaximumFrequency, value: newValue)
        }
    }

    /// Between 10 and 5000
    @objc open dynamic var notchWidth: Double = 1_000 {
        willSet {
            if notchWidth == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    notchWidthParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.notchWidth, value: newValue)
        }
    }

    /// Between 1.1 and 4
    @objc open dynamic var notchFrequency: Double = 1.5 {
        willSet {
            if notchFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    notchFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.notchFrequency, value: newValue)
        }
    }

    /// Direct or Vibrato (default)
    @objc open dynamic var vibratoMode: Double = 1 {
        willSet {
            if vibratoMode == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    vibratoModeParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.vibratoMode, value: newValue)
        }
    }

    /// Between 0 and 1
    @objc open dynamic var depth: Double = 1 {
        willSet {
            if depth == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    depthParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.depth, value: newValue)
        }
    }

    /// Between 0 and 1
    @objc open dynamic var feedback: Double = 0 {
        willSet {
            if feedback == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    feedbackParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.feedback, value: newValue)
        }
    }

    /// 1 or 0
    @objc open dynamic var inverted: Double = 0 {
        willSet {
            if inverted == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    invertedParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.inverted, value: newValue)
        }
    }

    /// Between 24 and 360
    @objc open dynamic var lfoBPM: Double = 30 {
        willSet {
            if lfoBPM == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    lfoBPMParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.lfoBPM, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
    ///   - vibratoMode: Direct or Vibrato (default)
    ///   - depth: Between 0 and 1
    ///   - feedback: Between 0 and 1
    ///   - inverted: 1 or 0
    ///   - lfoBPM: Between 24 and 360
    ///
    @objc public init(
        _ input: AKNode? = nil,
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
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
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

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        self.internalAU?.setParameterImmediately(.notchMinimumFrequency, value: notchMinimumFrequency)
        self.internalAU?.setParameterImmediately(.notchMaximumFrequency, value: notchMaximumFrequency)
        self.internalAU?.setParameterImmediately(.notchWidth, value: notchWidth)
        self.internalAU?.setParameterImmediately(.notchFrequency, value: notchFrequency)
        self.internalAU?.setParameterImmediately(.vibratoMode, value: vibratoMode)
        self.internalAU?.setParameterImmediately(.depth, value: depth)
        self.internalAU?.setParameterImmediately(.feedback, value: feedback)
        self.internalAU?.setParameterImmediately(.inverted, value: inverted)
        self.internalAU?.setParameterImmediately(.lfoBPM, value: lfoBPM)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
