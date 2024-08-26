// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Matrix Mixer allows you to map X input channels to Y output channels.
/// There is almost no documentation about how matrix mixer audio unit works.
/// This implementation is a result of consolidating various online resources:
/// - https://stackoverflow.com/questions/48059405/how-should-an-aumatrixmixer-be-configured-in-an-avaudioengine-graph
/// - https://stackoverflow.com/questions/16754037/how-to-use-aumatrixmixer
/// - https://lists.apple.com/archives/coreaudio-api/2008/Apr/msg00169.html
/// - https://lists.apple.com/archives/coreaudio-api/2006/Jul/msg00047.html
/// - https://lists.apple.com/archives/coreaudio-api/2008/Jun/msg00116.html
///
/// In order to be able to use Matrix Mixer, upstream connections will need to have
/// different format then downstream. Downstream connections are determined by
/// output node's channel count. But, for matrix mixer to be able to count input channels
/// correctly, upstream connections need to preserve source number of channels.
/// This can be done using `Node.outputFormat`.
///
/// Additionally, you might need to set audio format channel layout.
/// Even though it seems like `kAudioChannelLayoutTag_DiscreteInOrder` should be used, you will likely need `kAudioChannelLayoutTag_Unknown`
/// See:
/// https://www.mail-archive.com/coreaudio-api@lists.apple.com/msg01143.html
/// ```
/// let multiChannelLayout = AVAudioChannelLayout(
///     layoutTag: kAudioChannelLayoutTag_Unknown | outputFormat.channelCount
/// )!
/// ```

import AVFAudio

public class MatrixMixer: Node {
    private let inputs: [Node]

    public var connections: [Node] { inputs }
    public var avAudioNode: AVAudioNode { unit }

    /// Output format to be used when making connections from this node
    public var outputFormat = Settings.audioFormat

    public let unit = instantiate(
        componentDescription:
            AudioComponentDescription(
                componentType: kAudioUnitType_Mixer,
                componentSubType: kAudioUnitSubType_MatrixMixer,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        )

    public init(_ inputs: [Node]) {
        self.inputs = inputs
        // It is required to set element counts.
        // If we don't do it, running engine will throw
        // an exception when trying to dynamically connect
        // inputs to this mixer.
        var inputCount = UInt32(inputs.count)
        var outputCount = UInt32(1)
        var status = AudioUnitSetProperty(
            unit.audioUnit,
            kAudioUnitProperty_ElementCount,
            kAudioUnitScope_Input,
            0,
            &inputCount,
            UInt32(MemoryLayout<UInt32>.size)
        )
        CheckError(status)
        status = AudioUnitSetProperty(
            unit.audioUnit,
            kAudioUnitProperty_ElementCount,
            kAudioUnitScope_Output,
            0,
            &outputCount,
            UInt32(MemoryLayout<UInt32>.size)
        )
        CheckError(status)
    }

    private static let masterVolumeElement: AudioUnitElement = 0xFFFFFFFF

    /// Matrix Mixer master volume
    /// This is by default set to 0
    public var masterVolume: Float {
        get {
            var value: AudioUnitParameterValue = 0
            let status = AudioUnitGetParameter(
                unit.audioUnit,
                kMatrixMixerParam_Volume,
                kAudioUnitScope_Global,
                Self.masterVolumeElement,
                &value
            )
            CheckError(status)
            return value
        }
        set {
            let status = AudioUnitSetParameter(
                unit.audioUnit,
                kMatrixMixerParam_Volume,
                kAudioUnitScope_Global,
                Self.masterVolumeElement,
                newValue,
                0
            )
            CheckError(status)
        }
    }

    /// Matrix Mixer by default starts with all volumes set to 0
    /// Convenience method to unmute all inputs and outputs
    /// It is important to do this after the engine has started
    /// and node was connected. Otherwise, it will have no effect.
    public func unmuteAllInputsAndOutputs() {
        for i in 0..<inputChannelCount {
            set(volume: 1, inputChannelIndex: Int(i))
        }
        for i in 0..<outputChannelCount {
            set(volume: 1, outputChannelIndex: Int(i))
        }
    }

    public func set(volume: Float, inputChannelIndex: Int) {
        let status = AudioUnitSetParameter(
            unit.audioUnit,
            kMatrixMixerParam_Volume,
            kAudioUnitScope_Input,
            UInt32(inputChannelIndex),
            volume,
            0
        )
        CheckError(status)
    }

    /// Set volume of channel
    /// To map input channel 0 to output channel 1, use (0, 1) crosspoint
    public func set(volume: Float, outputChannelIndex: Int) {
        let status = AudioUnitSetParameter(
            unit.audioUnit,
            kMatrixMixerParam_Volume,
            kAudioUnitScope_Output,
            UInt32(outputChannelIndex),
            volume,
            0
        )
        CheckError(status)
    }

    /// Set volume at crosspoint
    /// To map input channel 0 to output channel 1, use (0, 1) crosspoint
    public func set(volume: Float, atCrosspoints crosspoints: [(Int, Int)]) {
        for crosspoint in crosspoints {
            let status = AudioUnitSetParameter(
                unit.audioUnit,
                kMatrixMixerParam_Volume,
                kAudioUnitScope_Global,
                (UInt32(crosspoint.0) << 16) | (UInt32(crosspoint.1) & 0x0000FFFF),
                volume,
                0
            )
            CheckError(status)
        }
    }

    /// Returns number of input channels in matrix mixer
    public var inputChannelCount: AVAudioChannelCount {
        inputs
            .map { $0.avAudioNode.outputFormat(forBus: 0).channelCount }
            .reduce(0, +)
    }

    /// Returns number of output channels in matrix mixer
    public var outputChannelCount: AVAudioChannelCount {
        unit.outputFormat(forBus: 0).channelCount
    }

    /// Returns matrix mixer levels 2 dimensional array.
    /// For more info about the format, see `kAudioUnitProperty_MatrixLevels` documentation.
    public var matrixLevels: [[Float32]] {
        let count = (inputChannelCount + 1) * (outputChannelCount + 1)
        var size = count * UInt32(MemoryLayout<Float32>.size)
        var volumes: [Float32] = Array(repeating: Float32(0), count: Int(count))

        AudioUnitGetProperty(
            unit.audioUnit,
            kAudioUnitProperty_MatrixLevels,
            kAudioUnitScope_Global,
            0,
            &volumes,
            &size
        )
        let chunkSize = Int(outputChannelCount + 1)
        return stride(from: 0, to: count, by: chunkSize).map {
            Array(volumes[Int($0)..<min(Int($0) + chunkSize, volumes.count)])
        }
    }

    /// It might be tricky to configure matrix mixer properly.
    /// Convenience method to print matrix levels and help you debugging.
    public func printMatrixLevels() {
        for (channel, chunk) in matrixLevels[0..<matrixLevels.count - 1].enumerated() {
            print("Input Channel \(channel) - \(chunk[0..<chunk.count - 1]), Input Volume \(chunk[chunk.count - 1])")
        }
        let last = matrixLevels[matrixLevels.count - 1]
        print("Output Volumes - \(last[0..<last.count - 1]), Master Volume \(last[last.count - 1])")
    }
}
