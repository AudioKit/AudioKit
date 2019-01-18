//
//  main.swift
//  AudiKit Sysex Example/Test
//
//  Created by Kurt Arnlund on 1/14/19.
//  Copyright © 2019 iatapps. All rights reserved.
//

import Foundation

let midiConnection = MidiConnectionManger()
midiConnection.selectIO()

print("")

let sysexCom = GeneralSysexCommunicationsManger()

var runUntilNote = true
let sysex_success = NotificationCenter.default.addObserver(forName: GeneralSysexCommunicationsManger.ReceivedSysex, object: nil, queue: nil) { (note) in
    runUntilNote = false
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

let sysex_timeout = NotificationCenter.default.addObserver(forName: GeneralSysexCommunicationsManger.SysexTimedOut, object: nil, queue: nil) { (note) in
    print("Communications Timeout")
    runUntilNote = false
    CFRunLoopStop(RunLoop.current.getCFRunLoop())
}

print("Sending Sysex Request")
sysexCom.requestAndWaitForResponse()

while (runUntilNote) {
    let oneSecondLater = Date(timeIntervalSinceNow: 0.0025)
    RunLoop.current.run(mode: .default, before: oneSecondLater)
}

NotificationCenter.default.removeObserver(sysex_success)
NotificationCenter.default.removeObserver(sysex_timeout)
