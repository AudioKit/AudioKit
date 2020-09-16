// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// A class that performs an action block, then starts a timer that
/// catches timeout conditions where a response is not received.
/// Since the external caller is responsible for what constitues succes,
/// they are expected to call succeed() which will prevent timeout from
/// happening.
@objc open class AKMIDITimeout: NSObject {
    private var onSuccess: ActionClosureType?
    private var onTimeout: ActionClosureType?
    let timeoutInterval: TimeInterval
    let mainThread: Bool

    public typealias ActionClosureType = () -> Void

    /// Control whether success and fail are sent.
    /// This provides a lot of flexibility in how this test app is used.
    /// If timeouts start to give you troubles, then just disable
    var disableSuccess = false
    var disableFailure = false

    public init(timeoutInterval time: TimeInterval,
                onMainThread: Bool = true,
                success: @escaping ActionClosureType,
                timeout: @escaping ActionClosureType) {
        mainThread = onMainThread
        timeoutInterval = time
        onSuccess = success
        onTimeout = timeout
        super.init()
    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(messageTimeout), object: nil)
    }

    public func perform(_ block: () -> Void) {
        DispatchQueue.main.async {
            self.perform(#selector(self.messageTimeout), with: nil, afterDelay: self.timeoutInterval)
        }
        block()
    }

    public func succeed() {
        mainthreadSuccessCall()
    }

    @objc func mainthreadSuccessCall() {
        let action: ActionClosureType = {
            NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                   selector: #selector(self.messageTimeout),
                                                   object: nil)
            if self.disableSuccess == false {
                self.onSuccess?()
            }
        }

        if mainThread {
            DispatchQueue.main.async( execute: action )
        } else {
            action()
        }
    }

    @objc func messageTimeout() {
        let action: ActionClosureType = {
            if self.disableFailure == false {
                self.onTimeout?()
            }
        }

        if mainThread {
            DispatchQueue.main.async( execute: action )
        } else {
            action()
        }
    }

}
