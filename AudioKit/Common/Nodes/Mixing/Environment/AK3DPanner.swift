//
//  AK3DPanner.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// 3-D Spatialization of the input
open class AK3DPanner: AKNode, AKInput {
    fileprivate let environmentNode = AVAudioEnvironmentNode()

    /// Position of sound source along x-axis
    @objc open dynamic var x: Double {
        willSet {
            environmentNode.listenerPosition.x = Float(-newValue)
        }
    }

    /// Position of sound source along y-axis
    @objc open dynamic var y: Double {
        willSet {
            environmentNode.listenerPosition.y = Float(-newValue)
        }
    }

    /// Position of sound source along z-axis
    @objc open dynamic var z: Double {
        willSet {
            environmentNode.listenerPosition.z = Float(-newValue)
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
    public init(_ input: AKNode? = nil, x: Double = 0, y: Double = 0, z: Double = 0) {
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
    open override func detach() {
        AudioKit.detach(nodes: [environmentNode, inputMixer.avAudioNode])
    }
}
