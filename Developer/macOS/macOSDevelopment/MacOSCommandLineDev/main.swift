//
//  main.swift
//  AudiKit Sysex Example/Test
//
//  Created by Kurt Arnlund on 1/14/19.
//  Copyright © 2019 iatapps. All rights reserved.
//

import Foundation
import AudioKit

let isTempoListener = true

let midiConnection = MIDIConnectionManger()
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

var tempoString: String = ""

if isTempoListener {
    bpm = midiConnection.tempoListener.tempoString
}

while receivedNotificaton == false {
    let oneSecondLater = Date(timeIntervalSinceNow: 0.002_5)
    RunLoop.current.run(mode: .default, before: oneSecondLater)

    if isTempoListener {
        let currentTempo = midiConnection.tempoListener.tempoString
        if tempoString != currentTempo {
            tempoString = currentTempo
//            debugPrint("Tempo: \(tempoString)")
        }
    }
}

NotificationCenter.default.removeObserver(sysexSuccess)
NotificationCenter.default.removeObserver(sysexTimeout)

midiConnection.closeAll()
print("Closed")
