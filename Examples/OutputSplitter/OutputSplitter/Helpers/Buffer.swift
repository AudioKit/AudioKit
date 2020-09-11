// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import CoreAudio

func makeBufferSilent(_ ioData: UnsafeMutableAudioBufferListPointer) {
    for buf in ioData {
        memset(buf.mData, 0, Int(buf.mDataByteSize))
    }
}
