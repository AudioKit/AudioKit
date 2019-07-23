//
//  Buffer.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation
import CoreAudio

func makeBufferSilent(_ ioData: UnsafeMutableAudioBufferListPointer) {
    for buf in ioData {
        memset(buf.mData, 0, Int(buf.mDataByteSize))
    }
}
