// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class ConstantGenerator: Node {
    public var connections: [Node] { [] }
    public private(set) var avAudioNode: AVAudioNode

    init(constant: Float) {
        avAudioNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = constant
                }
            }
            return noErr
        }
    }
}
