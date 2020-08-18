// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Brownian noise generator
///
public class AKBrownianNoise: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "bron")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: akGetParameterAddress("AKBrownianNoiseParameterAmplitude"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Amplitude. (Value between 0-1).
    @Parameter public var amplitude: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKBrownianNoise.amplitudeDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKBrownianNoiseDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this brown-noise node
    ///
    /// - Parameters:
    ///   - amplitude: Amplitude. (Value between 0-1).
    ///
    public init(
        amplitude: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.amplitude = amplitude

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

    }
}
