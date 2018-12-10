//
//  File.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 29/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import AudioKit

class Devices {
    static var output: [EZAudioDevice] {
        get {
            return EZAudioDevice.outputDevices() as! [EZAudioDevice]
        }
    }
}
