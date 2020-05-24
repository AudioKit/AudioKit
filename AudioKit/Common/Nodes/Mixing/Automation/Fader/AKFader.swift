// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Fader. Similar to AKBooster but with the addition of
/// Automation support.
open class AKFader: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {
    public typealias AKAudioUnitType = AKFaderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fder")

    public static var gainRange: ClosedRange<Double> = (0 ... 4)

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?
    public private(set) var parameterAutomation: AKParameterAutomation?

    /// Amplification Factor, from 0 ... 4
    @objc open var gain: Double = 1 {
        willSet {
            leftGain = gain
            rightGain = gain
        }
    }

    /// Left Channel Amplification Factor
    @objc open var leftGain: Double = 1 {
        willSet {
            let clampedValue = AKFader.gainRange.clamp(newValue)
            guard leftGain != clampedValue else { return }
            internalAU?.leftGain.value = AUValue(clampedValue)
        }
    }

    /// Right Channel Amplification Factor
    @objc open var rightGain: Double = 1 {
        willSet {
            let clampedValue = AKFader.gainRange.clamp(newValue)
            guard rightGain != clampedValue else { return }
            internalAU?.rightGain.value = AUValue(clampedValue)
        }
    }

    /// Amplification Factor in db
    @objc open var dB: Double {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Taper is a positive number where 1=Linear and the 0->1 and 1 and up represent curves on each side of linearity
    @objc open var taper: Double = 1 {
        willSet {
            let clampedValue = (0.0 ... 10.0).clamp(newValue)
            guard taper != clampedValue else { return }
            internalAU?.taper.value = AUValue(clampedValue)
        }
    }

    /// Skew ranges from zero to one where zero is easing In and 1 is easing Out. default 0.
    @objc open var skew: Double = 0 {
        willSet {
            let clampedValue = (0.0 ... 1.0).clamp(newValue)
            guard skew != clampedValue else { return }
            internalAU?.skew.value = AUValue(clampedValue)
        }
    }

    /// Offset allows you to start a ramp somewhere in the middle of it. default 0.
    @objc open var offset: Double = 0 {
        willSet {
            let clampedValue = (0.0 ... 1_000_000_000.0).clamp(newValue)
            guard offset != clampedValue else { return }
            internalAU?.offset.value = AUValue(clampedValue)
        }
    }

    /// Flip left and right signal
    @objc open var flipStereo: Bool = false {
        willSet {
            guard flipStereo != newValue else { return }
            internalAU?.flipStereo.value = newValue ? 1.0 : 0.0
        }
    }

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    @objc open var mixToMono: Bool = false {
        willSet {
            guard mixToMono != newValue else { return }
            internalAU?.mixToMono.value = newValue ? 1.0 : 0.0
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode? = nil,
                gain: Double = 1,
                taper: Double = 1,
                skew: Double = 0,
                offset: Double = 0) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.leftGain = gain
            self.rightGain = gain
            self.taper = taper
            self.skew = skew
            self.offset = offset

            if let internalAU = self.internalAU {
                self.parameterAutomation = AKParameterAutomation(internalAU, avAudioUnit: avAudioUnit)
            }
        }
    }

    deinit {
        AKLog("* { AKFader }")
    }

    open override func detach() {
        super.detach()
        parameterAutomation = nil
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.shouldBypassEffect = false
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.shouldBypassEffect = true
        internalAU?.stop()
    }

    // MARK: - AKAutomatable

    public func startAutomation(at audioTime: AVAudioTime?, duration: AVAudioTime?) {
        parameterAutomation?.start(at: audioTime, duration: duration)
    }

    public func stopAutomation() {
        parameterAutomation?.stop()
    }

    /// Convenience function for adding a pair of points for both left and right addresses
    public func addAutomationPoint(value: Double,
                                   at sampleTime: AUEventSampleTime,
                                   anchorTime: AUEventSampleTime,
                                   rampDuration: AUAudioFrameCount = 0,
                                   taper taperValue: Double? = nil,
                                   skew skewValue: Double? = nil,
                                   offset offsetValue: AUAudioFrameCount? = nil) {
        guard let leftAddress = internalAU?.leftGain.address,
            let rightAddress = internalAU?.rightGain.address else {
            AKLog("Param addresses aren't valid")
            return
        }

        // if a taper value is passed in, also add a point with its address to trigger at the same time
        if let taperValue = taperValue, let taperAddress = internalAU?.taper.address {
            parameterAutomation?.addPoint(taperAddress,
                                          value: AUValue(taperValue),
                                          sampleTime: sampleTime,
                                          anchorTime: anchorTime,
                                          rampDuration: rampDuration)
        }
        // if a skew value is passed in, also add a point with its address to trigger at the same time
        if let skewValue = skewValue, let skewAddress = internalAU?.skew.address {
            parameterAutomation?.addPoint(skewAddress,
                                          value: AUValue(skewValue),
                                          sampleTime: sampleTime,
                                          anchorTime: anchorTime,
                                          rampDuration: rampDuration)
        }

        // if an offset value is passed in, also add a point with its address to trigger at the same time
        if let offsetValue = offsetValue, let offsetAddress = internalAU?.offset.address {
            parameterAutomation?.addPoint(offsetAddress,
                                          value: AUValue(offsetValue),
                                          sampleTime: sampleTime,
                                          anchorTime: anchorTime,
                                          rampDuration: rampDuration)
        }

        parameterAutomation?.addPoint(leftAddress,
                                      value: AUValue(value),
                                      sampleTime: sampleTime,
                                      anchorTime: anchorTime,
                                      rampDuration: rampDuration)
        parameterAutomation?.addPoint(rightAddress,
                                      value: AUValue(value),
                                      sampleTime: sampleTime,
                                      anchorTime: anchorTime,
                                      rampDuration: rampDuration)
    }
}
