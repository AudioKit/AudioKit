// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AVAudioUnitEffect {
    convenience init(appleEffect subType: OSType) {
        self.init(audioComponentDescription: AudioComponentDescription(appleEffect: subType))
    }
}
