// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo Panner
///
public class AKPanner: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "pan2")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let panDef = AKNodeParameterDef(
        identifier: "pan",
        name: "Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.",
        address: akGetParameterAddress("AKPannerParameterPan"),
        range: -1 ... 1,
        unit: .generic,
        flags: .default)

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    @Parameter public var pan: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKPanner.panDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKPannerDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode? = nil,
        pan: AUValue = 0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.pan = pan
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }
}
