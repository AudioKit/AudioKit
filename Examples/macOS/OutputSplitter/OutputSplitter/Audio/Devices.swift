// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioKit

class Devices {
    static var output: [EZAudioDevice] {
        get {
            return EZAudioDevice.outputDevices() as! [EZAudioDevice]
        }
    }
}
