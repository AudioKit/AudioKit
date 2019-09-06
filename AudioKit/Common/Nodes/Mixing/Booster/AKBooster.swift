//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "bstr")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var leftGainParameter: AUParameter?
    fileprivate var rightGainParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    @objc open dynamic var rampType: AKSettings.RampType = .linear {
        willSet {
            internalAU?.rampType = newValue.rawValue
        }
    }

    fileprivate var lastKnownLeftGain: Double = 1.0
    fileprivate var lastKnownRightGain: Double = 1.0

    /// Amplification Factor
    @objc open dynamic var gain: Double = 1 {
        willSet {
            guard gain != newValue else { return }

            // ensure that the parameters aren't nil,
            // if they are we're using this class directly inline as an AKNode
            if internalAU?.isSetUp == true {
                leftGainParameter?.value = AUValue(newValue)
                rightGainParameter?.value = AUValue(newValue)
                return
            }

            // this means it's direct inline
            internalAU?.setParameterImmediately(.leftGain, value: newValue)
            internalAU?.setParameterImmediately(.rightGain, value: newValue)
        }
    }

    /// Left Channel Amplification Factor
    @objc open dynamic var leftGain: Double = 1 {
        willSet {
            guard leftGain != newValue else { return }
            if internalAU?.isSetUp == true {
                leftGainParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.leftGain, value: newValue)
        }
    }

    /// Right Channel Amplification Factor
    @objc open dynamic var rightGain: Double = 1 {
        willSet {
            guard rightGain != newValue else { return }
            if internalAU?.isSetUp == true {
                rightGainParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.rightGain, value: newValue)
        }
    }

    /// Amplification Factor in db
    @objc open dynamic var dB: Double {
        set { self.gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(self.gain) }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return self.internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    @objc public init(_ input: AKNode? = nil,
                      gain: Double = 1) {
        self.leftGain = gain
        self.rightGain = gain

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
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        self.leftGainParameter = tree["leftGain"]
        self.rightGainParameter = tree["rightGain"]

        self.internalAU?.setParameterImmediately(.leftGain, value: gain)
        self.internalAU?.setParameterImmediately(.rightGain, value: gain)
        self.internalAU?.setParameterImmediately(.rampDuration, value: self.rampDuration)
        self.internalAU?.rampType = self.rampType.rawValue
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            self.leftGain = lastKnownLeftGain
            self.rightGain = self.lastKnownRightGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            self.lastKnownLeftGain = leftGain
            self.lastKnownRightGain = rightGain
            self.leftGain = 1
            self.rightGain = 1
        }
    }

    let renderCallback: AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer,
         ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
         inTimeStamp: UnsafePointer<AudioTimeStamp>,
         inBusNumber: UInt32,
         inNumberFrames: UInt32,
         ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in

        guard ioActionFlags.pointee == AudioUnitRenderActionFlags.unitRenderAction_PreRender ||
            ioActionFlags.pointee == AudioUnitRenderActionFlags.offlineUnitRenderAction_Complete else {
            return noErr
        }
        let booster = Unmanaged<AKBooster>.fromOpaque(inRefCon).takeUnretainedValue()
        let sampleTime = AUEventSampleTime(inTimeStamp.pointee.mSampleTime)
        booster.handleRenderCallback(at: sampleTime, inNumberFrames: inNumberFrames)
        return noErr
    }

    internal func handleRenderCallback(at sampleTime: AUEventSampleTime, inNumberFrames: UInt32) {
        guard !self.automationPoints.isEmpty else { return }

        // AKLog(sampleTime)

        // where block.sampleTime >= sampleTime
        for point in self.automationPoints {
            for i in 0 ..< inNumberFrames {
                // if fmod(sampleTime + Double(i), Double(block.sampleTime)) == 0 {
                if sampleTime + AUEventSampleTime(i) == point.sampleTime {
                    if let address = point.address {
                        AKLog("👉 firing value", point.value, "at", sampleTime, "rampType", point.rampType)
                        self.rampDuration = Double(point.rampDuration) / outputNode.outputFormat(forBus: 0).sampleRate
                        self.rampType = point.rampType
                        self.internalAU?.scheduleParameterBlock(AUEventSampleTimeImmediate + AUEventSampleTime(i),
                                                                point.rampDuration,
                                                                address,
                                                                point.value)
                    }
                }
            }
        }
    }

    private var _automationEnabled: Bool = false
    var automationEnabled: Bool {
        get {
            return self._automationEnabled
        }
        set {
            guard newValue != self._automationEnabled,
                let audioUnit = avAudioUnit?.audioUnit else {
                return
            }

            let inRefCon = UnsafeMutableRawPointer(Unmanaged<AKBooster>.passUnretained(self).toOpaque())

            if newValue {
                AudioUnitAddRenderNotify(audioUnit, self.renderCallback, inRefCon)
            } else {
                AudioUnitRemoveRenderNotify(audioUnit, self.renderCallback, inRefCon)
            }

            self._automationEnabled = newValue
        }
    }

    internal var automationPoints = [AKParameterAutomationPoint]()
}

extension AKBooster {
    public func clearAutomation() {
        self.automationPoints.removeAll()
    }

    public func addAutomationPoint(value: Double, at time: AUEventSampleTime, rampDuration: AUAudioFrameCount? = nil, rampType: AKSettings.RampType = .linear) {
        guard let leftAddress = leftGainParameter?.address,
            let rightAddress = rightGainParameter?.address else {
            AKLog("Param addresses aren't valid")
            return
        }

        // self.rampDuration = Double(rampDuration) / outputNode.outputFormat(forBus: 0).sampleRate

        guard let lastRenderTime = avAudioNode.lastRenderTime?.audioTimeStamp.mSampleTime else {
            return
        }

        let lastTimeStamp = AUEventSampleTime(lastRenderTime)

        // clear old events
        self.automationPoints = self.automationPoints.filter {
            $0.sampleTime >= lastTimeStamp
        }

        // add a future offset to the last rendered time
        let sampleTime = lastTimeStamp + time

        let rampDuration = rampDuration ?? 0 // AUAudioFrameCount(0.2 * outputNode.outputFormat(forBus: 0).sampleRate)

        let pointL = AKParameterAutomationPoint(sampleTime: sampleTime, rampDuration: rampDuration, rampType: rampType, address: leftAddress, value: AUValue(value))
        let pointR = AKParameterAutomationPoint(sampleTime: sampleTime, rampDuration: rampDuration, rampType: rampType, address: rightAddress, value: AUValue(value))

        automationPoints.append(pointL)
        automationPoints.append(pointR)

        AKLog("* lastTimeStamp", lastTimeStamp, "sampleTime", sampleTime, "rampDuration", rampDuration, "value", value, "rampType", rampType)
        // AKLog("Automation list:", automationPoints)
    }
}

//typedef void (^AUScheduleParameterBlock)(AUEventSampleTime eventSampleTime, AUAudioFrameCount rampDurationSampleFrames, AUParameterAddress parameterAddress, AUValue value);
internal struct AKParameterAutomationPoint {
    var sampleTime: AUEventSampleTime = 0
    var rampDuration: AUAudioFrameCount = 0
    var rampType: AKSettings.RampType = .linear
    var address: AUParameterAddress?
    var value: AUValue = 0
}
