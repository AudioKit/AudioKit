//
//  GeneralSysexCommunicationsManger.swift
//  
//  Created by Kurt Arnlund on 1/12/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//

import Foundation
import AudioKit

let SEND_SYSEX = false

extension Notification.Name {
    static let ReceivedSysex = Notification.Name(rawValue: "ReceivedSysexNotification")
    static let SysexTimedOut = Notification.Name(rawValue: "SysexTimedOutNotification")

}

/// A class responsible for sending sysex messages and informing a caller of
/// reception of a sysex response, or a timeout error condition.
open class GeneralSysexCommunicationsManger: AKMIDIListener {

    let midi = AudioKit.midi
    let synthK5000 = K5000messages()
//    let midiCi = MidiCiMessage(deviceId: .toFromMidiPort, subId2: <#T##midiCiSubID2#>)

    /// Defaults to 44 seconds, which is just a bit longer than it takes
    /// the largest K5000 sysex messages to be received.
    let timeoutInterval = TimeInterval(44)
    let messageTimeout: AKMIDITimeout

    init() {
        messageTimeout = AKMIDITimeout(timeoutInterval: timeoutInterval, success: {
            NotificationCenter.default.post(name: .ReceivedSysex, object: nil)
        }, timeout: {
            NotificationCenter.default.post(name: .SysexTimedOut, object: nil)
        })
        midi.addListener(self)
    }

    deinit {
        midi.removeListener(self)
    }

    // MARK: - Request

    public func requestAndWaitForResponse() {
        messageTimeout.perform {
            if SEND_SYSEX {
                // K5000
                // Very fast requests
                let sysexMessage = synthK5000.oneSingleAreaA(channel: .channel0, patch: 0)
//                let sysexMessage = synthK5000.oneCombinationAreaC(channel: .channel0, combi: 0)
//                let sysexMessage = synthK5000.oneSingleAreaD(channel: .channel0, patch: 0)
//                let sysexMessage = synthK5000.oneSingleAreaE(channel: .channel0, patch: 0)
//                let sysexMessage = synthK5000.oneSingleAreaF(channel: .channel0, patch: 0)
                // Very slow requests
//                let sysexMessage = synthK5000.blockSingleAreaA(channel: .channel0)
//                let sysexMessage = synthK5000.blockCombinationAreaC(channel: .channel0)
//                let sysexMessage = synthK5000.blockSingleAreaD(channel: .channel0)
//                let sysexMessage = synthK5000.blockSingleAreaE(channel: .channel0)
//                let sysexMessage = synthK5000.blockSingleAreaF(channel: .channel0)

                // MIDI CI

                midi.sendMessage(sysexMessage)
            }
        }
    }

    // MARK: - AKMIDIListener

    public func receivedMIDISystemCommand(_ data: [MIDIByte], time: MIDITimeStamp = 0) {
        guard data[0] == AKMIDISystemCommand.sysex.rawValue else {
            return
        }
        // Look for a response from a K5000 that always starts with these bytes
        // 240, 64, <K5000sysexChannel>, 32, 0, 10, <memory area 0, 0 >
        let responseK5000blockAreaA: [MIDIByte]     = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x00, 0x00]
        let responseK5000singleAreaA: [MIDIByte]    = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x00, 0x00]
        let responseK5000blockAreaBPcm: [MIDIByte]  = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x00, 0x01]
        let responseK5000singleAreaBPcm: [MIDIByte] = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x00, 0x01]
        let responseK5000drumKitB117: [MIDIByte]        = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x11]
        let responseK5000drumInstAreaU: [MIDIByte]      = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x11]
        let responseK5000blockCombiAreaC: [MIDIByte]    = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x20]
        let responseK5000singleCombiAreaC: [MIDIByte]   = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x20]
        let responseK5000blockAreaD: [MIDIByte]     = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x00, 0x02]
        let responseK5000singleAreaD: [MIDIByte]    = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x00, 0x02]
        let responseK5000blockAreaE: [MIDIByte]     = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x00, 0x03]
        let responseK5000singleAreaE: [MIDIByte]    = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x00, 0x03]
        let responseK5000blockAreaF: [MIDIByte]     = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x21, 0x00, 0x0A, 0x00, 0x04]
        let responseK5000singleAreaF: [MIDIByte]    = [0xF0, 0x40, K5000sysexChannel.channel0.rawValue, 0x20, 0x00, 0x0A, 0x00, 0x04]
        let headers = [responseK5000singleAreaA, responseK5000blockAreaA,
                       responseK5000blockAreaBPcm, responseK5000singleAreaBPcm,
                       responseK5000drumKitB117, responseK5000drumInstAreaU,
                       responseK5000blockCombiAreaC, responseK5000singleCombiAreaC,
                       responseK5000blockAreaD, responseK5000singleAreaD,
                       responseK5000blockAreaE, responseK5000singleAreaE,
                       responseK5000blockAreaF, responseK5000singleAreaF]

        for header in headers {
            let dataheader = data.dropLast(data.count - header.count)
            let headertuple = zip(dataheader, header)
            if headersMatch(headertuple) {
                messageTimeout.succeed()
                debugPrint("Received sysex header reponse from K5000")
                debugPrint(data)
                break
            }
        }
    }

    func headersMatch(_ headerTuple: Zip2Sequence<ArraySlice<MIDIByte>, [MIDIByte]>) -> Bool {
        return headerTuple.contains { $0.0 != $0.1 }
    }

}
