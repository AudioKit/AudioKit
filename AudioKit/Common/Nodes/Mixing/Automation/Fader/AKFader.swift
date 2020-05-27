// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Fader. Similar to AKBooster but with the addition of
/// Automation support.
open class AKFader: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {
    
    // MARK: - AKComponent
    
    public typealias AKAudioUnitType = AKFaderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fder")
    
    public private(set) var internalAU: AKAudioUnitType?
    
    // MARK: - AKAutomatable
    
    public private(set) var parameterAutomation: AKParameterAutomation?
    
    // MARK: - Parameters
    
    public static var gainRange: ClosedRange<AUValue> = (0 ... 4)
    
    /// Amplification Factor, from 0 ... 4
    open var gain: AUValue = 1 {
        willSet {
            leftGain.value = gain
            rightGain.value = gain
        }
    }

    /// Left Channel Amplification Factor
    public let leftGain = AKNodeParameter(identifier: "leftGain")

    /// Right Channel Amplification Factor
    public let rightGain = AKNodeParameter(identifier: "rightGain")

    /// Amplification Factor in db
    public var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Flip left and right signal
    public let flipStereo = AKNodeParameter(identifier: "flipStereo")

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    public let mixToMono = AKNodeParameter(identifier: "mixToMono")

    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: AKNode? = nil,
                gain: AUValue = 1,
                offset: AUValue = 0) {
        super.init(avAudioNode: AVAudioNode())
        
        instantiateAudioUnit() { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(self.internalAU, avAudioUnit: avAudioUnit)

            self.leftGain.associate(with: self.internalAU, value: gain)
            self.rightGain.associate(with: self.internalAU, value: gain)
            self.flipStereo.associate(with: self.internalAU, value: false)
            self.mixToMono.associate(with: self.internalAU, value: false)
            
            input?.connect(to: self)
        }
    }

    deinit {
        AKLog("* { AKFader }")
    }

    open override func detach() {
        super.detach()
        parameterAutomation = nil
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
//        guard let leftAddress = internalAU?.leftGain.address,
//            let rightAddress = internalAU?.rightGain.address else {
//            AKLog("Param addresses aren't valid")
//            return
//        }
//
//        // if a taper value is passed in, also add a point with its address to trigger at the same time
//        if let taperValue = taperValue, let taperAddress = internalAU?.taper.address {
//            parameterAutomation?.addPoint(taperAddress,
//                                          value: AUValue(taperValue),
//                                          sampleTime: sampleTime,
//                                          anchorTime: anchorTime,
//                                          rampDuration: rampDuration)
//        }
//        // if a skew value is passed in, also add a point with its address to trigger at the same time
//        if let skewValue = skewValue, let skewAddress = internalAU?.skew.address {
//            parameterAutomation?.addPoint(skewAddress,
//                                          value: AUValue(skewValue),
//                                          sampleTime: sampleTime,
//                                          anchorTime: anchorTime,
//                                          rampDuration: rampDuration)
//        }
//
//        // if an offset value is passed in, also add a point with its address to trigger at the same time
//        if let offsetValue = offsetValue, let offsetAddress = internalAU?.offset.address {
//            parameterAutomation?.addPoint(offsetAddress,
//                                          value: AUValue(offsetValue),
//                                          sampleTime: sampleTime,
//                                          anchorTime: anchorTime,
//                                          rampDuration: rampDuration)
//        }
//
//        parameterAutomation?.addPoint(leftAddress,
//                                      value: AUValue(value),
//                                      sampleTime: sampleTime,
//                                      anchorTime: anchorTime,
//                                      rampDuration: rampDuration)
//        parameterAutomation?.addPoint(rightAddress,
//                                      value: AUValue(value),
//                                      sampleTime: sampleTime,
//                                      anchorTime: anchorTime,
//                                      rampDuration: rampDuration)
    }
}
