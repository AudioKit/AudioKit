//
//  Audiobus+MIDI.swift
//  AudiobusMIDISender
//
//  Created by Jeff Holtzkener on 2018/03/28.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import Foundation
import AudioKit

extension Audiobus {

    // MARK: - Preparations
    class func addMIDISenderPort(_ port: ABMIDISenderPort) {
        guard let client = client else {
            AKLog("need to start Audiobus")
            return
        }

        client.controller.addMIDISenderPort(port)
    }

    class func setUpEnableCoreMIDIBlock(block: ((Bool) -> Void)!) {
        guard let client = client else {
            AKLog("need to start Audiobus")
            return
        }

        client.controller.enableSendingCoreMIDIBlock = block
    }

    // MARK: - Triggers
    class func addTrigger(_ trigger: ABTrigger) {
        guard let client = client else {
            AKLog("need to start Audiobus")
            return
        }
        client.controller.add(trigger)
    }

    // MARK: - Send MIDI Messages
    class func sendNoteOnMessage(midiSendPort: ABMIDISenderPort, status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        let noteCommand = MIDIByte(0x90) + channel
        let data = [noteCommand, note, velocity]
        sendMessage(midiSendPort: midiSendPort, data: data)
    }

    class func sendNoteOffMessage(midiSendPort: ABMIDISenderPort, status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        let noteCommand = MIDIByte(0x80) + channel
        let data = [noteCommand, note, velocity]
        sendMessage(midiSendPort: midiSendPort, data: data)
    }

    class func sendMessage(midiSendPort: ABMIDISenderPort, data: [MIDIByte]) {
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.allocate(capacity: 1)
        var packet = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1_024, packet, 0, data.count, data)
        ABMIDIPortSendPacketList(midiSendPort, UnsafePointer(packetListPointer))
    }
}
