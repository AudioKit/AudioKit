// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation
import CAudioKit

/// Get the raw data for any node
open class RawDataTap: BaseTap {
    /// Array of Raw data
    open var data: [Float]
    /// Callback type
    public typealias Handler = ([Float]) -> Void

    private var handler: Handler = { _ in }

    /// Initialize the raw data tap
    ///
    /// - parameter input: Node to analyze
    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Callback to call when results are available
    public init(_ input: Node, bufferSize: UInt32 = 1_024, handler: @escaping Handler = { _ in }) {
        self.data = Array(repeating: 0.0, count: Int(bufferSize))
        self.handler = handler
        super.init(input, bufferSize: bufferSize)
    }

    // AVAudioNodeTapBlock - time is unused in this case
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
