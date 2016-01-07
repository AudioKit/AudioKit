//
//  File.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKNoiseInstrument: AKMidiInstrument{
    
    public var white:Bool = true
    public var pink:Bool{
        return !white
    }
    
    public init(white: Bool = true, voiceCount: Int) {
        //by default will init as white noise, pass in false to convert to pink
        self.white = white
        if white {
            super.init(voice: AKWhiteNoise(), voiceCount: voiceCount)
        } else {
            super.init(voice: AKPinkNoise(), voiceCount: voiceCount)
        }
    }
    public override func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        let amplitude = Double(velocity)/127.0
        if white {
            let voiceEntity = voices[voice] as! AKWhiteNoise
            voiceEntity.amplitude = amplitude
            voiceEntity.start()
        } else {
            let voiceEntity = voices[voice] as! AKPinkNoise
            voiceEntity.amplitude = amplitude
            voiceEntity.start()
        }
    }
    public override func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        if white {
            let voiceEntity = voices[voice] as! AKWhiteNoise
            voiceEntity.amplitude = 0
            voiceEntity.stop()
        } else {
            let voiceEntity = voices[voice] as! AKPinkNoise
            voiceEntity.amplitude = 0
            voiceEntity.stop()
        }
    }
}
