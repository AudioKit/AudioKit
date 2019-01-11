//
//  Application.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioKit

class Application {
    static var engine: Engine!
    static var output1: Output?
    static var output2: Output?

    static func start () {
        engine = Engine()
        selectOutputDevice1(device: EZAudioDevice.currentOutput()!)
    }

    static func selectOutputDevice1 (device: EZAudioDevice) {
        print("Creating an Output1 Engine for Device: " + device.name)
        output1 = Output(device: device, engine: engine)
    }

    static func selectOutputDevice2 (device: EZAudioDevice) {
        print("Creating an Output2 Engine for Device: " + device.name)
        output2 = Output(device: device, engine: engine)
    }

}
