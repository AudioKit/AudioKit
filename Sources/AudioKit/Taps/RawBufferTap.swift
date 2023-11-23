// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Get the raw buffer from any node
open class RawBufferTap: BaseTap {
    /// Callback type
    public typealias Handler = (AVAudioPCMBuffer, AVAudioTime) -> Void

    private let handler: Handler

    /// Initialize the raw buffer tap
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer
    ///   - handler: Callback to call on each pcm buffer received
    public init(_ input: Node, bufferSize: UInt32 = 4096, callbackQueue: DispatchQueue = .main, handler: @escaping Handler) {
        self.handler = handler
        super.init(input, bufferSize: bufferSize, callbackQueue: callbackQueue)
    }

    override public func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        handler(buffer, time)
    }
}
