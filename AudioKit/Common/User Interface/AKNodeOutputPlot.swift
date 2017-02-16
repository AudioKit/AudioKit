//
//  AKNodeOutputPlot.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Plot the output from any node in an signal processing graph
@IBDesignable
open class AKNodeOutputPlot: EZAudioPlot {

    internal func setupNode(_ input: AKNode?) {
        input?.avAudioNode.installTap(onBus: 0,
                                      bufferSize: bufferSize,
                                      format: nil) { [weak self] (buffer, _) in

            guard let strongSelf = self else {
                return
            }
            buffer.frameLength = strongSelf.bufferSize
            let offset = Int(buffer.frameCapacity - buffer.frameLength)
            let tail = buffer.floatChannelData?[0]
            strongSelf.updateBuffer(&tail![offset],
                                    withBufferSize: strongSelf.bufferSize)
        }
    }

    internal var bufferSize: UInt32 = 1_024

    /// The node whose output to graph
    open var node: AKNode? {
        willSet {
            node?.avAudioNode.removeTap(onBus: 0)
        }
        didSet {
            setupNode(node)
        }
    }

    deinit {
        node?.avAudioNode.removeTap(onBus: 0)
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode(nil)
    }

    /// Initialize the plot with the output from a given node and optional plot size
    ///
    /// - Parameters:
    ///   - input: AKNode from which to get the plot data
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    public init(_ input: AKNode, frame: CGRect, bufferSize: Int = 1_024) {
        super.init(frame: frame)
        self.plotType = .buffer
        self.backgroundColor = AKColor.white
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)

        setupNode(input)
    }
}
