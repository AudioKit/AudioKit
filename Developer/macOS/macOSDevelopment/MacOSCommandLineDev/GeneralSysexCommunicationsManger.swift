//
//  GeneralSysexCommunicationsManger.swift
//  
//  Created by Kurt Arnlund on 1/12/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//

import Foundation
import AudioKit

/// A class that performs an action block, then starts a timer that
/// catches timeout conditions where a response is not received.
/// Since the external caller is responsible for what constitues succes,
/// they are expected to call succeed() which will prevent timeout from
/// happening.
open class SuccessOrTimeoutMgr: NSObject {
    private var onSuccess: (() -> Void)?
    private var onTimeout: (() -> Void)?
    let timeoutInterval: TimeInterval

    init(timeoutInterval time: TimeInterval, success: @escaping () -> Void, timeout: @escaping () -> Void) {
        timeoutInterval = time
        onSuccess = success
        onTimeout = timeout
        super.init()
    }

    open func performWithTimeout(_ block: () -> Void) {
        self.perform(#selector(messageTimeout), with: nil, afterDelay: timeoutInterval)
        block()
    }

    public func succeed() {
        print("success")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(messageTimeout), object: nil)
        self.onSuccess?()
    }

    @objc func messageTimeout() {
        print("timed out")
        self.onTimeout?()
    }
}

/// A class responsible for sending sysex messages and informing a caller of
/// reception of a sysex response, or a timeout error condition.
open class GeneralSysexCommunicationsManger: AKMIDIListener {
    static let ReceivedSysex = Notification.Name(rawValue: "ReceivedSysexNotification")
    static let SysexTimedOut = Notification.Name(rawValue: "SysexTimedOutNotification")

    let midi = AudioKit.midi
    let synthK5000 = K5000messages()

    /// Defaults to 44 seconds, which is just a bit longer than it takes
    /// the largest K5000 sysex messages to be received.
    let timeoutInterval = TimeInterval(44)
    let messageTimeout: SuccessOrTimeoutMgr

    init() {
        messageTimeout = SuccessOrTimeoutMgr(timeoutInterval: timeoutInterval, success: {
        NotificationCenter.default.post(name: GeneralSysexCommunicationsManger.ReceivedSysex, object: nil)
        }) timeout: {
            NotificationCenter.default.post(name: GeneralSysexCommunicationsManger.SysexTimedOut, object: nil)
        }
        midi.addListener(self)
    }

    // MARK: - Request

    public func requestAndWaitForResponse() {
        messageTimeout.performWithTimeout( {
            // Very fast requests
            let sysexMessage = synthK5000.oneSingleAreaA(channel: .channel0, patch: 0)
//            let sysexMessage = synthK5000.oneCombinationAreaC(channel: .channel0, combi: 0)
//            let sysexMessage = synthK5000.oneSingleAreaD(channel: .channel0, patch: 0)
//            let sysexMessage = synthK5000.oneSingleAreaE(channel: .channel0, patch: 0)
//            let sysexMessage = synthK5000.oneSingleAreaF(channel: .channel0, patch: 0)

            // Very slow requests
//            let sysexMessage = synthK5000.blockSingleAreaA(channel: .channel0)
//            let sysexMessage = synthK5000.blockCombinationAreaC(channel: .channel0)
//            let sysexMessage = synthK5000.blockSingleAreaD(channel: .channel0)
//            let sysexMessage = synthK5000.blockSingleAreaE(channel: .channel0)
//            let sysexMessage = synthK5000.blockSingleAreaF(channel: .channel0)

            midi.sendMessage(sysexMessage)
        })
    }

    // MARK: - AKMIDIListener

    public func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        guard data[0] == AKMIDISystemCommand.sysex.rawValue else {
            return
        }
        print("Received MIDI data: \(data)")
        messageTimeout.succeed()
    }

}
