//
//  GeneralSysexCommunicationsManger.swift
//  
//  Created by Kurt Arnlund on 1/12/19.
//  Copyright © 2019 iatapps. All rights reserved.
//
//

import Foundation
import AudioKit

open class SuccessOrTimeoutMgr : NSObject {
    private var onSuccess : (() -> Void)?
    private var onTimeout : (() -> Void)?
    let timeoutInterval : TimeInterval

    init(timeoutInterval t: TimeInterval, success: @escaping () -> Void, timeout: @escaping () -> Void) {
        timeoutInterval = t
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

open class GeneralSysexCommunicationsManger : AKMIDIListener {
    static let ReceivedSysex = Notification.Name(rawValue: "ReceivedSysexNotification")
    static let SysexTimedOut = Notification.Name(rawValue: "SysexTimedOutNotification")

    let midi = AudioKit.midi
    let K5000 = K5000_messages()

    let timeoutInterval = TimeInterval(44)
    let messageTimeout: SuccessOrTimeoutMgr

    init() {
        messageTimeout = SuccessOrTimeoutMgr(timeoutInterval: timeoutInterval, success: {
        NotificationCenter.default.post(name: GeneralSysexCommunicationsManger.ReceivedSysex, object: nil)
        }) {
            NotificationCenter.default.post(name: GeneralSysexCommunicationsManger.SysexTimedOut, object: nil)
        }
        midi.addListener(self)
    }

    public func requestAndWaitForResponse() {
        messageTimeout.performWithTimeout( {
            // Very fast requests
            let sysexMessage = K5000.one_single_ADD_A(channel: .channel_0, patch: 0)
//            let sysexMessage = K5000.one_combination_C(channel: .channel_0, combi: 0)
//            let sysexMessage = K5000.one_single_ADD_D(channel: .channel_0, patch: 0)
//            let sysexMessage = K5000.one_single_ADD_E(channel: .channel_0, patch: 0)
//            let sysexMessage = K5000.one_single_ADD_F(channel: .channel_0, patch: 0)

            // Very slow requests
//            let sysexMessage = K5000.block_single_ADD_A(channel: .channel_0)
//            let sysexMessage = K5000.block_combination_C(channel: .channel_0)
//            let sysexMessage = K5000.block_single_ADD_D(channel: .channel_0)
//            let sysexMessage = K5000.block_single_ADD_E(channel: .channel_0)
//            let sysexMessage = K5000.block_single_ADD_F(channel: .channel_0)

            midi.sendMessage(sysexMessage)
        })
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        guard data[0] == AKMIDISystemCommand.sysex.rawValue else {
            return
        }
        print("Received MIDI data: \(data)")
        messageTimeout.succeed()
    }

}
