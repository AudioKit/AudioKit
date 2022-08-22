// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio

class CustomFormatReverb: Node {
    private let reverb: Reverb
    var avAudioNode: AVAudioNode { reverb.avAudioNode }
    var connections: [Node] { reverb.connections }
    var outputFormat: AVAudioFormat

    init(_ input: Node, outputFormat: AVAudioFormat) {
        self.reverb = Reverb(input)
        self.outputFormat = outputFormat
    }
}
