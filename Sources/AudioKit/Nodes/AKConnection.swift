// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Simplify making connections from a node.
public protocol AKOutput: AnyObject {

    /// The output of this node can be connected to the inputNode of an AKInput.
    var outputNode: AVAudioNode { get }
}

extension AKOutput {

    /// Output connection points of outputNode.
    public var connectionPoints: [AVAudioConnectionPoint] {
        get { return outputNode.engine?.outputConnectionPoints(for: outputNode, outputBus: 0) ?? [] }
        set {
            //AKManager.connect(outputNode, to: newValue, fromBus: 0, format: AKSettings.audioFormat)
        }
    }

    /// Disconnects all outputNode's output connections.
    public func disconnectOutput() {
        AKManager.engine.disconnectNodeOutput(outputNode)
    }

    /// Add an output connectionPoint.
    ///   - Parameter connectionPoint: Input that will be connected to.
    public func connect(to connectionPoint: AVAudioConnectionPoint) {
        connectionPoints.append(connectionPoint)
    }


    /// Sets output connections to a single connectionPoint, removes previously existing output connections.
    ///   - Parameter connectionPoint: Input that output will be connected to.
    public func setOutput(to connectionPoint: AVAudioConnectionPoint) {
        setOutput(to: connectionPoint, format: AKSettings.audioFormat)
    }

    /// Sets output connections to a single connectionPoint, removes previously existing output connections.
    ///   - Parameter connectionPoint: Input that output will be connected to.
    ///   - Parameter format: The format of the connections.
    public func setOutput(to connectionPoint: AVAudioConnectionPoint, format: AVAudioFormat?) {
        setOutput(to: [connectionPoint], format: format)
    }

    /// Sets output connections to an array of connectionPoints, removes previously existing output connections.
    ///   - Parameter connectionPoints: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    public func setOutput(to connectionPoints: [AVAudioConnectionPoint], format: AVAudioFormat?) {
//        AKManager.connect(outputNode, to: connectionPoints, fromBus: 0, format: format)
    }

}
