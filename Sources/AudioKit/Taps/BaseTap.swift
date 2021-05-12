// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Foundation

/// Base class for AudioKit taps using AVAudioEngine installTap
open class BaseTap {
    /// Size of buffer to analyze
    public private(set) var bufferSize: UInt32

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

    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Callback to call
    public init(_ input: Node, bufferSize: UInt32) {
        self.bufferSize = bufferSize
        self._input = input
    }

    /// Enable the tap on input
    public func start() {
        lock()
        defer {
            unlock()
        }
        guard !isStarted else { return }
        isStarted = true

        // a node can only have one tap at a time installed on it
        // make sure any previous tap is removed.
        // We're making the assumption that the previous tap (if any)
        // was installed on the same bus as our bus var.
        removeTap()

        // just double check this here
        guard input.avAudioNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioNode.installTap(onBus: bus,
                                           bufferSize: bufferSize,
                                           format: nil,
                                           block: handleTapBlock(buffer:at:))
    }

    /// Overide this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    private func handleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        // Call on the main thread so the client doesn't have to worry
        // about thread safety.
        buffer.frameLength = bufferSize
        DispatchQueue.main.async {
            // Create trackers as needed.
            self.lock()
            guard self.isStarted == true else {
                self.unlock()
                return
            }
            self.doHandleTapBlock(buffer: buffer, at: time)
            self.unlock()
        }
    }

    /// Overide this method to handle Tap in derived class
    open func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {}

    /// Remove the tap on the input
    public func stop() {
        lock()
        removeTap()
        isStarted = false
        unlock()
    }

    private func removeTap() {
        guard input.avAudioNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }
        input.avAudioNode.removeTap(onBus: bus)
    }

    /// remove the tap and nil out the input reference
    /// this is important in regard to retain cycles on your input node
    public func dispose() {
        if isStarted {
            stop()
        }
    }

    private var unfairLock = os_unfair_lock_s()
    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
