// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Get the raw data for any node
open class RawDataTap: BaseTap {
    /// Array of Raw data
    open var data: [Float]
    /// Callback type
    public typealias Handler = ([Float]) -> Void

    private var handler: Handler = { _ in }

    /// Initialize the raw data tap
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer to analyze
    ///   - handler: Callback to call when results are available
    public init(_ input: Node, bufferSize: UInt32 = 1_024, callbackQueue: DispatchQueue = .main, handler: @escaping Handler = { _ in }) {
        self.data = Array(repeating: 0.0, count: Int(bufferSize))
        self.handler = handler
        super.init(input, bufferSize: bufferSize, callbackQueue: callbackQueue)
    }

    /// Override this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    override open func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard buffer.floatChannelData != nil else { return }

        let offset = Int(buffer.frameCapacity - buffer.frameLength)
        var tempData = [Float]()
        if let tail = buffer.floatChannelData?[0] {
            for idx in 0 ..< bufferSize {
                tempData.append(tail[offset + Int(idx)])
            }
        }
        data = tempData
        handler(data)
    }

    /// Remove the tap on the input
    override public func stop() {
        super.stop()
        for i in 0 ..< data.count { data[i] = 0.0 }
    }
}

public actor RawDataTap2: Tap {

    /// Callback type
    public typealias Handler = ([Float]) -> Void

    private let handler: Handler

    public init(_ input: Node, handler: @escaping Handler = { _ in }) {
        self.handler = handler
    }

    public func handleTap(buffer: AVAudioPCMBuffer, at time: AVAudioTime) async {
        guard buffer.floatChannelData != nil else { return }

        let offset = Int(buffer.frameCapacity - buffer.frameLength)
        var data = [Float]()
        if let tail = buffer.floatChannelData?[0] {
            // XXX: fixme hard coded 1024
            for idx in 0 ..< 1024 {
                data.append(tail[offset + Int(idx)])
            }
        }

        handler(data)
    }
}
