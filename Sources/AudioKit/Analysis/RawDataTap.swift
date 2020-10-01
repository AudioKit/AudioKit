// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Accelerate
import CAudioKit

/// FFT Calculation for any node
open class RawDataTap: Toggleable {

    /// Size of buffer to
    public private(set) var bufferSize: UInt32

    /// Array of Raw data
    open var data: [Float]

    /// Tells whether the node is processing (ie. started, playing, or active)
    public private(set) var isStarted: Bool = false

    /// The bus to install the tap onto
    public var bus: Int = 0 {
        didSet {
            if isStarted {
                stop()
                start()
            }
        }
    }

    private var _input: Node

    /// Input node to analyze
    public var input: Node {
        get {
            return _input
        }
        set {
            guard newValue !== _input else { return }
            let wasStarted = isStarted

            // if the input changes while it's on, stop and start the tap
            if wasStarted {
                stop()
            }

            _input = newValue

            // if the input changes while it's on, stop and start the tap
            if wasStarted {
                start()
            }
        }
    }

    /// Callback type
    public typealias Handler = ([Float]) -> Void

    private var handler: Handler = { _ in }

    /// Initialize the raw data tap
    /// 
    /// - parameter input: Node to analyze
    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Callback to call when results are available
    public init(_ input: Node, bufferSize: UInt32 = 4_096, handler: @escaping Handler) {
        self.bufferSize = bufferSize
        self._input = input
        self.handler = handler
        self.data = Array(repeating: 0.0, count: Int(bufferSize))
    }

    /// Enable the tap on input
    public func start() {
        guard !isStarted else { return }
        isStarted = true

        // a node can only have one tap at a time installed on it
        // make sure any previous tap is removed.
        // We're making the assumption that the previous tap (if any)
        // was installed on the same bus as our bus var.
        removeTap()

        // just double check this here
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.installTap(onBus: bus,
                                           bufferSize: bufferSize,
                                           format: nil,
                                           block: handleTapBlock(buffer:at:))
    }

    // AVAudioNodeTapBlock - time is unused in this case
    private func handleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {

        guard buffer.floatChannelData != nil else { return }

        // Call on the main thread so the client doesn't have to worry
        // about thread safety.
        DispatchQueue.main.sync {
            let arraySize = Int(buffer.frameLength)
            data = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:arraySize))
            handler(data)
        }
    }

    /// Remove the tap on the input
    public func stop() {
        removeTap()
        isStarted = false
        for i in 0 ..< data.count { data[i] = 0.0 }
    }

    private func removeTap() {
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// remove the tap and nil out the input reference
    /// this is important in regard to retain cycles on your input node
    public func dispose() {
        if isStarted {
            stop()
        }
    }
}
