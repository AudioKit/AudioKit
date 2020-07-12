// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    public typealias AKAudioUnitType = AKPhaserAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Notch Minimum Frequency
    @Parameter public var notchMinimumFrequency: AUValue

    /// Notch Maximum Frequency
    @Parameter public var notchMaximumFrequency: AUValue

    /// Between 10 and 5000
    @Parameter public var notchWidth: AUValue

    /// Between 1.1 and 4
    @Parameter public var notchFrequency: AUValue

    /// Direct or Vibrato (default)
    @Parameter public var vibratoMode: AUValue

    /// Between 0 and 1
    @Parameter public var depth: AUValue

    /// Between 0 and 1
    @Parameter public var feedback: AUValue

    /// 1 or 0
    @Parameter public var inverted: AUValue

    /// Between 24 and 360
    @Parameter public var lfoBPM: AUValue

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
    public init(
        _ input: AKNode? = nil,
        notchMinimumFrequency: AUValue = 100,
        notchMaximumFrequency: AUValue = 800,
        notchWidth: AUValue = 1_000,
        notchFrequency: AUValue = 1.5,
        vibratoMode: AUValue = 1,
        depth: AUValue = 1,
        feedback: AUValue = 0,
        inverted: AUValue = 0,
        lfoBPM: AUValue = 30
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.notchMinimumFrequency = notchMinimumFrequency
        self.notchMaximumFrequency = notchMaximumFrequency
        self.notchWidth = notchWidth
        self.notchFrequency = notchFrequency
        self.vibratoMode = vibratoMode
        self.depth = depth
        self.feedback = feedback
        self.inverted = inverted
        self.lfoBPM = lfoBPM
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
