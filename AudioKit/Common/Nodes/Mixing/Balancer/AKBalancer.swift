// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This node outputs a version of the audio source, amplitude-modified so
/// that its rms power is equal to that of the comparator audio source. Thus a
/// signal that has suffered loss of power (eg., in passing through a filter
/// bank) can be restored by matching it with, for instance, its own source. It
/// should be noted that this modifies amplitude only; output signal is not
/// altered in any other respect.
///
open class AKBalancer: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBalancerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(mixer: "blnc")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this balance node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - comparator: Audio to match power with
    ///
    @objc public init(_ input: AKNode? = nil, comparator: AKNode) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self)
            comparator.connect(to: self, bus: 1)
        }
    }
}
