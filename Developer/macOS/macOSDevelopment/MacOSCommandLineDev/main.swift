//
//  main.swift
//  AudiKit Sysex Example/Test
//
//  Created by Kurt Arnlund on 1/14/19.
//  Copyright © 2019 iatapps. All rights reserved.
//

import Foundation
import AudioKit

let bpmListener = true

let midiConnection = MidiConnectionManger()
midiConnection.openAll()

print("")

let sysexCom = GeneralSysexCommunicationsManger()

var receivedNotificaton = false
let sysex_success = NotificationCenter.default.addObserver(forName: GeneralSysexCommunicationsManger.ReceivedSysex, object: nil, queue: nil) { (note) in
    receivedNotificaton = true
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

let sysex_timeout = NotificationCenter.default.addObserver(forName: GeneralSysexCommunicationsManger.SysexTimedOut, object: nil, queue: nil) { (note) in
    print("Communications Timeout")
    receivedNotificaton = true
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

print("Sending Sysex Request")
//sysexCom.requestAndWaitForResponse()

var bpm: BpmType = 0

if bpmListener {
    bpm = midiConnection.bpmListenter.bpm
}

while receivedNotificaton == false {
    let oneSecondLater = Date(timeIntervalSinceNow: 0.0025)
    RunLoop.current.run(mode: .default, before: oneSecondLater)

    if bpmListener {
        let currentBmp = midiConnection.bpmListenter.bpm
        if bpm != currentBmp {
            bpm = currentBmp
//            print("BPM: \(bpm)")
        }
    }
}

NotificationCenter.default.removeObserver(sysex_success)
NotificationCenter.default.removeObserver(sysex_timeout)

midiConnection.closeAll()
print("Closed")
