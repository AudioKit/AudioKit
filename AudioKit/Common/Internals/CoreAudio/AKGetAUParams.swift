//
//  AKGetAUParams.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Audio from the standard input */
public struct AKGetAUParams {
    
    private func getAUParams(_ inputAU: AudioUnit) -> ([AudioUnitParameterInfo]) {
        //  Get number of parameters in this unit (size in bytes really):
        var size: UInt32 = 0
        var propertyBool = DarwinBoolean(true)
        
        AudioUnitGetPropertyInfo(
            inputAU,
            kAudioUnitProperty_ParameterList,
            kAudioUnitScope_Global,
            0,
            &size,
            &propertyBool)
        let numParams = Int(size)/sizeof(AudioUnitParameterID.self)
        var parameterIDs = [AudioUnitParameterID](repeating: 0, count: Int(numParams))
        AudioUnitGetProperty(
            inputAU,
            kAudioUnitProperty_ParameterList,
            kAudioUnitScope_Global,
            0,
            &parameterIDs,
            &size)
        var paramInfo = AudioUnitParameterInfo()
        var outParams = [AudioUnitParameterInfo]()
        var parameterInfoSize: UInt32 = UInt32(sizeof(AudioUnitParameterInfo.self))
        for paramID in parameterIDs {
            AudioUnitGetProperty(
                inputAU,
                kAudioUnitProperty_ParameterInfo,
                kAudioUnitScope_Global,
                paramID,
                &paramInfo,
                &parameterInfoSize)
            outParams.append(paramInfo)
            print(paramID)
            print("Paramer name :\(paramInfo.cfNameString?.takeUnretainedValue()) | " +
                "Min:\(paramInfo.minValue) | " +
                "Max:\(paramInfo.maxValue) | " +
                "Default: \(paramInfo.defaultValue)")
        }
        return outParams
    }
}
