//
//  AudioKit+Status.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AudioKit {
    
    var isIaaConnected:Bool{
        var connected:UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.stride)
        let mainAudioUnit = AudioKit.engine.outputNode.audioUnit!
        AudioUnitGetProperty(mainAudioUnit,
                             kAudioUnitProperty_IsInterAppConnected,
                             kAudioUnitScope_Global, 0, &connected, &dataSize);
        return Bool(truncating: connected as NSNumber)
    }
}
