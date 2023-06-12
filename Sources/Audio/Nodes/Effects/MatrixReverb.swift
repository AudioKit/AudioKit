// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import AVFoundation
import Utilities

#if os(macOS)

/// AudioKit version of Apple's Reverb Audio Unit
///
public class MatrixReverb: Node {
    public var auAudioUnit: AUAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry-Wet Mix",
        address: AUParameterAddress(kReverbParam_DryWetMix),
        defaultValue: 100,
        range: 0.0 ... 100.0,
        unit: .generic
    )

    /// Dry/Wet equal power crossfarde. Should be a value between 0-100.
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue

    /// Specification details for small large mix
    public static let smallLargeMixDef = NodeParameterDef(
        identifier: "smallLargeMix",
        name: "Small-Large Mix",
        address: AUParameterAddress(kReverbParam_SmallLargeMix),
        defaultValue: 50,
        range: 0.0 ... 100.0,
        unit: .generic
    )

    /// Small/Large mix. Should be a value between 0-100. Default 50.
    @Parameter(smallLargeMixDef) public var smallLargeMix: AUValue

    /// Specification details for small size
    public static let smallSizeDef = NodeParameterDef(
        identifier: "smallSize",
        name: "Small Size",
        address: AUParameterAddress(kReverbParam_SmallSize),
        defaultValue: 0.06,
        range: 0.005 ... 0.020,
        unit: .seconds
    )

    /// Small Size. Should be a value between 0.005-0.020. Default 0.06.
    @Parameter(smallSizeDef) public var smallSize: AUValue

    /// Specification details for large size
    public static let largeSizeDef = NodeParameterDef(
        identifier: "largeSize",
        name: "Large Size",
        address: AUParameterAddress(kReverbParam_LargeSize),
        defaultValue: 3.07,
        range: 0.4 ... 10.0,
        unit: .seconds
    )

    /// Large Size. Should be a value between 0.4-10.0. Default 3.07.
    @Parameter(largeSizeDef) public var largeSize: AUValue

    /// Specification details for pre-delay
    public static let preDelayDef = NodeParameterDef(
        identifier: "preDelay",
        name: "Pre-Delay",
        address: AUParameterAddress(kReverbParam_PreDelay),
        defaultValue: 0.025,
        range: 0.001 ... 0.03,
        unit: .seconds
    )

    /// Pre-Delay. Should be a value between 0.001-0.03. Default 0.025.
    @Parameter(preDelayDef) public var preDelay: AUValue

    /// Specification details for large delay
    public static let largeDelayDef = NodeParameterDef(
        identifier: "largeDelay",
        name: "Large Delay",
        address: AUParameterAddress(kReverbParam_LargeDelay),
        defaultValue: 0.035,
        range: 0.001 ... 0.1,
        unit: .seconds
    )

    /// Large Delay. Should be a value between 0.001-0.1. Default 0.035.
    @Parameter(largeDelayDef) public var largeDelay: AUValue

    /// Specification details for
    public static let smallDensityDef = NodeParameterDef(
        identifier: "smallDensity",
        name: "Small Density",
        address: AUParameterAddress(kReverbParam_SmallDensity),
        defaultValue: 0.28,
        range: 0 ... 1,
        unit: .generic
    )

    /// Small Density. Should be a value between 0-1. Default 0.28.
    @Parameter(smallDensityDef) public var smallDensity: AUValue

    /// Specification details for large density
    public static let largeDensityDef = NodeParameterDef(
        identifier: "largeDensity",
        name: "Large Density",
        address: AUParameterAddress(kReverbParam_LargeDensity),
        defaultValue: 0.82,
        range: 0 ... 1,
        unit: .generic
    )

    /// Large Density. Should be a value between 0-1. Default 0.82.
    @Parameter(largeDensityDef) public var largeDensity: AUValue

    /// Specification details for large delay
    public static let largeDelayRangeDef = NodeParameterDef(
        identifier: "largeDelayRange",
        name: "Large Delay Range",
        address: AUParameterAddress(kReverbParam_LargeDelayRange),
        defaultValue: 0.3,
        range: 0 ... 1,
        unit: .generic
    )

    /// Large Delay Range. Should be a value between 0-1. Default 0.3.
    @Parameter(largeDelayRangeDef) public var largeDelayRange: AUValue

    /// Specification details for small brightness
    public static let smallBrightnessDef = NodeParameterDef(
        identifier: "smallBrightness",
        name: "Small Brightness",
        address: AUParameterAddress(kReverbParam_SmallBrightness),
        defaultValue: 0.96,
        range: 0.1 ... 1,
        unit: .generic
    )

    /// Small Brightness. Should be a value between 0.1-1. Default 0.96.
    @Parameter(smallBrightnessDef) public var smallBrightness: AUValue

    /// Specification details for large brightness
    public static let largeBrightnessDef = NodeParameterDef(
        identifier: "largeBrightness",
        name: "Large Brightness",
        address: AUParameterAddress(kReverbParam_LargeBrightness),
        defaultValue: 0.49,
        range: 0.1 ... 1,
        unit: .generic
    )

    /// Large Brightness. Should be a value between 0.1-1. Default 0.49.
    @Parameter(largeBrightnessDef) public var largeBrightness: AUValue

    /// Specification details for small deelay range
    public static let smallDelayRangeDef = NodeParameterDef(
        identifier: "smallDelayRange",
        name: "Small Delay Range",
        address: AUParameterAddress(kReverbParam_SmallDelayRange),
        defaultValue: 0.5,
        range: 0 ... 1,
        unit: .generic
    )

    /// Small Delay Range. Should be a value between 0-1. Default 0.5.
    @Parameter(smallDelayRangeDef) public var smallDelayRange: AUValue

    /// Specification details for modulation rate
    public static let modulationRateDef = NodeParameterDef(
        identifier: "modulationRate",
        name: "Modulation Rate",
        address: AUParameterAddress(kReverbParam_ModulationRate),
        defaultValue: 1.0,
        range: 0.001 ... 2.0,
        unit: .hertz
    )

    /// Modulation Rate. Should be a value between 0.001-2.0. Default 1.0.
    @Parameter(modulationRateDef) public var modulationRate: AUValue

    /// Specification details for modulation depth
    public static let modulationDepthDef = NodeParameterDef(
        identifier: "modulationDepth",
        name: "Modulation Depth",
        address: AUParameterAddress(kReverbParam_ModulationDepth),
        defaultValue: 0.2,
        range: 0.0 ... 1.0,
        unit: .generic
    )

    /// Modulation Depth. Should be a value between 0.0-1.0. Default 0.2.
    @Parameter(modulationDepthDef) public var modulationDepth: AUValue

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: ReverbPreset) {
        let auPreset = AUAudioUnitPreset()
        auPreset.number = preset.rawValue
        auAudioUnit.currentPreset = auPreset
    }

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: Node to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 100, Range: 0 - 100)
    ///
    public init(_ input: Node,
                dryWetMix: AUValue = 100,
                smallLargeMix: AUValue = 50,
                smallSize: AUValue = 0.06,
                largeSize: AUValue = 3.07,
                preDelay: AUValue = 0.025,
                largeDelay: AUValue = 0.035,
                smallDensity: AUValue = 0.28,
                largeDensity: AUValue = 0.82,
                largeDelayRange: AUValue = 0.3,
                smallBrightness: AUValue = 0.96,
                largeBrightness: AUValue = 0.49,
                smallDelayRange: AUValue = 0.5,
                modulationRate: AUValue = 1.0,
                modulationDepth: AUValue = 0.2)
    {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_MatrixReverb)
        auAudioUnit = instantiateAU(componentDescription: desc)
        associateParams(with: auAudioUnit)

        self.dryWetMix = dryWetMix
        self.smallLargeMix = smallLargeMix
        self.smallSize = smallSize
        self.largeSize = largeSize
        self.preDelay = preDelay
        self.largeDelay = largeDelay
        self.smallDensity = smallDensity
        self.largeDensity = largeDensity
        self.largeDelayRange = largeDelayRange
        self.smallBrightness = smallBrightness
        self.largeBrightness = largeBrightness
        self.smallDelayRange = smallDelayRange
        self.modulationRate = modulationRate
        self.modulationDepth = modulationDepth
        AudioEngine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        AudioEngine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
    }
}

#endif // os(macOS)
