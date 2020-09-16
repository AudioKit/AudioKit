// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import CAudioKit
import CoreGraphics


/// Plot the output from any node in an signal processing graph
///
/// By default this plots the output of engine.output
public class AKNodeOutputPlot2: AKWaveform {

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

                    let arraySize = Int(buffer.frameLength)
                    let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:arraySize))
                    strongSelf.fill(with: [samples])
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
        super.init()
//        super.init(channels: 1, size: frame.size, waveformColor: UIColor.red.cgColor, backgroundColor: UIColor.black.cgColor)
//        self.plotType = .buffer
//        self.channels = 1
//        self.backgroundColor = AKColor.white
//        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)
    }

    public func start() {
        setupNode(node)
    }
}

