// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

/// Guitar head and cab simulator.
///
public class AKRhinoGuitarProcessor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKRhinoGuitarProcessorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "dlrh")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Determines the amount of gain applied to the signal before processing.
    public var preGain: AUValue = 5.0 {
        willSet {
            guard preGain != newValue else { return }
            internalAU?.preGain.value = newValue
        }
    }

    /// Gain applied after processing.
    public var postGain: AUValue = 0.7 {
        willSet {
            guard postGain != newValue else { return }
            internalAU?.postGain.value = (AUValue(0)...AUValue(1)).clamp(newValue)
        }
    }

    /// Amount of Low frequencies.
    public var lowGain: AUValue = 0.0 {
        willSet {
            guard lowGain != newValue else { return }
            internalAU?.lowGain.value = newValue
        }
    }

    /// Amount of Middle frequencies.
    public var midGain: AUValue = 0.0 {
        willSet {
            guard midGain != newValue else { return }
            internalAU?.midGain.value = newValue
        }
    }

    /// Amount of High frequencies.
    public var highGain: AUValue = 0.0 {
        willSet {
            guard highGain != newValue else { return }
            internalAU?.highGain.value = newValue
        }
    }

    /// Distortion Amount
    public var distortion: AUValue = 1.0 {
        willSet {
            guard distortion != newValue else { return }
            internalAU?.distortion.value = newValue
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this Rhino head and cab simulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - preGain: Determines the amount of gain applied to the signal before processing.
    ///   - postGain: Gain applied after processing.
    ///   - lowGain: Amount of Low frequencies.
    ///   - midGain: Amount of Middle frequencies.
    ///   - highGain: Amount of High frequencies.
    ///   - distortion: Distortion Amount
    ///
    public init(
        _ input: AKNode? = nil,
        preGain: AUValue = 5.0,
        postGain: AUValue = 0.7,
        lowGain: AUValue = 0.0,
        midGain: AUValue = 0.0,
        highGain: AUValue = 0.0,
        distortion: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self)

            self.preGain = preGain
            self.postGain = postGain
            self.lowGain = lowGain
            self.midGain = midGain
            self.highGain = highGain
            self.distortion = distortion
        }
    }
}
