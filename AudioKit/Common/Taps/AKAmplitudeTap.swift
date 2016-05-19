//
//  AKRMS.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKRMS {
    internal let bufferSize: UInt32 = 1024
    public init(_ input: AKNode) {
        input.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AudioKit.format) {
            (buffer, time) in
            
            var sum: Float = 0
            
            // do a quick calc from the buffer values
            for i in 0 ..< Int(self.bufferSize) {
                sum += pow(Float(buffer.floatChannelData.memory[i]), 2)
            }
            
            print(NSString(format:"%0.5f",sqrt(sum/Float(self.bufferSize))))
        }
    }
}