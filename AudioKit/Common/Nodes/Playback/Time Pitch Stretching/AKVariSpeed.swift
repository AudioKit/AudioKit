// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's VariSpeed Audio Unit
///
open class AKVariSpeed: AKNode, AKToggleable, AKInput {

    fileprivate let variSpeedAU = AVAudioUnitVarispeed()

    /// Rate (rate) ranges form 0.25 to 4.0 (Default: 1.0)
    @objc open dynamic var rate: AUValue = 1.0 {
        didSet {
            rate = (0.25...4).clamp(rate)
            variSpeedAU.rate = rate
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return rate != 1.0
    }

    fileprivate var lastKnownRate: AUValue = 1.0

    /// Initialize the varispeed node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
    ///
    @objc public init(_ input: AKNode? = nil, rate: AUValue = 1.0) {
        self.rate = rate
        lastKnownRate = rate

        super.init(avAudioNode: AVAudioNode())
        avAudioUnit = variSpeedAU
        avAudioNode = variSpeedAU
        AKManager.engine.attach(avAudioUnitOrNode)
        input?.connect(to: self)
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        rate = lastKnownRate
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        lastKnownRate = rate
        rate = 1.0
    }
}
