// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

/// `AUNewPitch` audio unit
/// This is different to `AUNewTimePitch` (`AVAudioUnitTimePitch`).
/// `AUNewTimePitch` does both time stretching and pitch shifting.
/// `AUNewTimePitch` is `AVAudioUnitTimeEffect` and `AUNewPitch` is `AVAudioUnitEffect`
public class NewPitch: Node {
    private let input: Node
    private let pitchUnit = instantiate(
        componentDescription: AudioComponentDescription(appleEffect: kAudioUnitSubType_NewTimePitch)
    )

    public var connections: [AudioKit.Node] { [input] }
    public var avAudioNode: AVAudioNode { pitchUnit }

    /// Initialize the time pitch node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    public init(_ input: Node) {
        self.input = input
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    /// NOTE: Base value of pitch is 1.0.
    /// This means that the value of 1 is the state where no pitch shifing is applied.
    public var pitch: AUValue {
        get { AudioUnitGetParameter(pitchUnit.audioUnit, param: kNewTimePitchParam_Pitch) }
        set { AudioUnitSetParameter(pitchUnit.audioUnit, param: kNewTimePitchParam_Pitch, to: newValue) }
    }
}
