// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import CAudioKit
import CoreGraphics

extension Notification.Name {
    static let IAAConnected = Notification.Name(rawValue: "IAAConnected")
    static let IAADisconnected = Notification.Name(rawValue: "IAADisconnected")
}

/// Plot the output from any node in an signal processing graph
///
/// By default this plots the output of engine.output
public class NodeOutputPlot: EZAudioPlot {

    /// Keep track of connection
    public var isConnected = false

    /// Avoiding bangs
    public var isNotConnected: Bool { return !isConnected }

    /// Set up node
    /// - Parameter input: Input node
    public func setupNode(_ input: Node) {
        if isNotConnected {
            input.avAudioUnitOrNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: nil) { [weak self] (buffer, _) in

                    guard let strongSelf = self else {
                        Log("Unable to create strong reference to self")
                        return
                    }
                    buffer.frameLength = strongSelf.bufferSize
                    let offset = Int(buffer.frameCapacity - buffer.frameLength)
                    if let tail = buffer.floatChannelData?[0] {
                        strongSelf.updateBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
                    }
            }
        }
        isConnected = true
    }

    /// Pause plot
    public func pause() {
        if isConnected {
            node.avAudioUnitOrNode.removeTap(onBus: 0)
            isConnected = false
        }
    }

    /// Resume plot
    public func resume() {
        setupNode(node)
    }

    internal var bufferSize: UInt32 = 1_024

    /// Node to plot
    open var node: Node {
        willSet {
            pause()
        }
        didSet {
            resume()
        }
    }

    deinit {
        removeTap()
    }

    /// Remove the tap
    public func removeTap() {
        guard node.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        node.avAudioUnitOrNode.removeTap(onBus: 0)
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Stop using interface builder.")
    }

    /// Initialize the plot with the output from a given node and optional plot size
    ///
    /// - Parameters:
    ///   - input: Node from which to get the plot data
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    public init(_ input: Node, frame: CGRect = CGRect.zero, bufferSize: Int = 1_024) {
        self.node = input
        super.init(frame: frame)
        self.plotType = .buffer
        self.backgroundColor = .white
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)
    }

    /// Start the plot
    public func start() {
        setupNode(node)
    }
}

