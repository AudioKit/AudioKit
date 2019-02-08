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
let sysexSuccess = NotificationCenter.default.addObserver(forName: .ReceivedSysex, object: nil, queue: nil) { (note) in
    receivedNotificaton = true
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

let sysexTimeout = NotificationCenter.default.addObserver(forName: .SysexTimedOut, object: nil, queue: nil) { (note) in
    print("Communications Timeout")
    receivedNotificaton = true
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

print("Sending Sysex Request")
//sysexCom.requestAndWaitForResponse()

var bpm: String = ""

if bpmListener {
    bpm = midiConnection.bpmListenter.tempoString
}

while receivedNotificaton == false {
    let oneSecondLater = Date(timeIntervalSinceNow: 0.0025)
    RunLoop.current.run(mode: .default, before: oneSecondLater)

    if bpmListener {
        let currentBmp = midiConnection.bpmListenter.tempoString
        if bpm != currentBmp {
            bpm = currentBmp
//            debugPrint("BPM: \(bpm)")
        }
    }
}

NotificationCenter.default.removeObserver(sysexSuccess)
NotificationCenter.default.removeObserver(sysexTimeout)

midiConnection.closeAll()
print("Closed")
