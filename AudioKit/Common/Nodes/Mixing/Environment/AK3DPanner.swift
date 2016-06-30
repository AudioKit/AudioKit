//
//  AK3DPanner.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 6/5/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/// 3-D Spatialization of the input
public class AK3DPanner: AKNode {
    private let environmentNode = AVAudioEnvironmentNode()
    
    
    /// Position of sound source along x-axis
    public var x: Double {
        willSet {
            environmentNode.listenerPosition.x = Float(-newValue)
        }
    }
    
    /// Position of sound source along y-axis
    public var y: Double {
        willSet {
            environmentNode.listenerPosition.y = Float(-newValue)
        }
    }
    
    /// Position of sound source along z-axis
    public var z: Double {
        willSet {
            environmentNode.listenerPosition.z = Float(-newValue)
        }
    }
    
    /// Initialize the panner node
    ///
    /// - Parameters:
    ///   - input: Node to pan in 3D Space
    ///   - x:     x-axis location in meters
    ///   - y:     y-axis location in meters
    ///   - z:     z-axis location in meters
    ///
    public init(_ input: AKNode, x: Double = 0, y: Double = 0, z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
        super.init()

        self.avAudioNode = environmentNode
        AudioKit.engine.attachNode(self.avAudioNode)
        input.connectionPoints.append(AVAudioConnectionPoint(node: environmentNode, bus: environmentNode.numberOfInputs))
        
        let format = AVAudioFormat(standardFormatWithSampleRate: AKSettings.sampleRate, channels: 1)
        
        AudioKit.engine.connect(input.avAudioNode, toConnectionPoints: input.connectionPoints, fromBus: 0, format: format)
    }

}
