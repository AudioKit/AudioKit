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
public class AKNodeOutputPlot: EZAudioPlot {

    public var isConnected = false
    public var isNotConnected: Bool { return !isConnected }

    public func setupNode(_ input: AKNode) {
        if isNotConnected {
            input.avAudioUnitOrNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: nil) { [weak self] (buffer, _) in

                    guard let strongSelf = self else {
                        AKLog("Unable to create strong reference to self")
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

    public func pause() {
        if isConnected {
            node.avAudioUnitOrNode.removeTap(onBus: 0)
            isConnected = false
        }
    }

    public func resume() {
        setupNode(node)
    }

    internal var bufferSize: UInt32 = 1_024

    open var node: AKNode {
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

    public func removeTap() {
        guard node.avAudioUnitOrNode.engine != nil else {
            AKLog("The tapped node isn't attached to the engine")
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
    ///   - input: AKNode from which to get the plot data
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    public init(_ input: AKNode, frame: CGRect = CGRect.zero, bufferSize: Int = 1_024) {
        self.node = input
        super.init(frame: frame)
        self.plotType = .buffer
        self.backgroundColor = AKColor.white
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)
    }

    public func start() {
        setupNode(node)
    }
}

