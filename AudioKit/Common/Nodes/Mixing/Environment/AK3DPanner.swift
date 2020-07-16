// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 3-D Spatialization of the input
public class AK3DPanner: AKNode, AKInput {
    fileprivate let environmentNode = AVAudioEnvironmentNode()

    /// Position of sound source along x-axis
    public var x: AUValue {
        willSet {
            environmentNode.listenerPosition.x = -newValue
        }
    }

    /// Position of sound source along y-axis
    public var y: AUValue {
        willSet {
            environmentNode.listenerPosition.y = -newValue
        }
    }

    /// Position of sound source along z-axis
    public var z: AUValue {
        willSet {
            environmentNode.listenerPosition.z = -newValue
        }
    }

    var inputMixer = AKMixer()
    /// Initialize the panner node
    ///
    /// - Parameters:
    ///   - input: Node to pan in 3D Space
    ///   - x:     x-axis location in meters
    ///   - y:     y-axis location in meters
    ///   - z:     z-axis location in meters
    ///
    public init(_ input: AKNode? = nil, x: AUValue = 0, y: AUValue = 0, z: AUValue = 0) {
        self.x = x
        self.y = y
        self.z = z
        super.init(avAudioNode: environmentNode, attach: true)

        input?.connect(to: inputMixer)

        let monoFormat = AVAudioFormat(standardFormatWithSampleRate: AKSettings.sampleRate, channels: 1)
        inputMixer.setOutput(to: environmentNode, bus: 0, format: monoFormat)

    }
    public var inputNode: AVAudioNode {
        return inputMixer.avAudioNode
    }
    public override func detach() {
        AKManager.detach(nodes: [environmentNode, inputMixer.avAudioNode])
    }
}
