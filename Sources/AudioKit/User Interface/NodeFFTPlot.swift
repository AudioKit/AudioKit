// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CAudioKit
import Accelerate
import Foundation

/// Plot the FFT output from any node in an signal processing graph
public class NodeFFTPlot: EZAudioPlot, EZAudioFFTDelegate {

    /// Is the FFT Plot connected to a node
    public var isConnected = false

    /// Is the FFT Plot not connected to a node
    public var isNotConnected: Bool { return !isConnected }

    internal func setupNode(_ input: Node) {
        if isNotConnected {
            if fft == nil {
                fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize),
                                 sampleRate: Float(Settings.sampleRate),
                                 delegate: self)
            }

            input.avAudioUnitOrNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: nil) { [weak self] (buffer, _) in
                    if let strongSelf = self {
                        buffer.frameLength = strongSelf.bufferSize
                        let offset = Int(buffer.frameCapacity - buffer.frameLength)
                        if let tail = buffer.floatChannelData?[0], let existingFFT = strongSelf.fft {
                            existingFFT.computeFFT(withBuffer: &tail[offset],
                                                   withBufferSize: strongSelf.bufferSize)
                        }
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

    // EZAudioFFT container
    fileprivate var fft: EZAudioFFT?

    /// The node whose output to graph
    open var node: Node {
        willSet {
            pause()
        }
        didSet {
            resume()
        }
    }

    deinit {
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

    /// Callback function for FFT data:
    ///
    /// - Parameters:
    ///   - fft: EZAudioFFT Reference
    ///   - updatedWithFFTData: A pointer to a c-style array of floats
    ///   - bufferSize: Number of elements in the FFT Data array
    ///
    public func fft(_ fft: EZAudioFFT!,
                    updatedWithFFTData fftData: UnsafeMutablePointer<Float>,
                    bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            self.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }

    /// Start the plot
    public func start() {
        setupNode(node)
    }
}
