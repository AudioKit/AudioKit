// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import Foundation

/// Class to handle updating via CADisplayLink
public class CallbackLoop: NSObject {
    private var internalHandler: () -> Void = {}
    public var duration = 1.0
    public var frequency: Double {
        get {
            1.0 / duration
        }
        set {
            duration = 1.0 / newValue
        }
    }
    private var isRunning = false

    /// Repeat this loop at a given period with a code block
    ///
    /// - parameter period: Interval between block executions
    /// - parameter handler: Code block to execute
    ///
    public init(every period: Double, handler: @escaping () -> Void) {
        duration = period
        internalHandler = handler
        super.init()
        update()
    }

    /// Repeat this loop at a given frequency with a code block
    ///
    /// - parameter frequency: Frequency of block executions in Hz
    /// - parameter handler: Code block to execute
    ///
    public init(frequency: Double, handler: @escaping () -> Void) {
        duration = 1.0 / frequency
        internalHandler = handler
        super.init()
        update()
    }

    public func start() {
        isRunning = true
        update()
    }

    public func stop() {
        isRunning = false
    }

    /// Callback function
    @objc func update() {
        if isRunning {
            self.internalHandler()
            self.perform(#selector(update),
                         with: nil,
                         afterDelay: duration,
                         inModes: [.common])
        }
    }
}
