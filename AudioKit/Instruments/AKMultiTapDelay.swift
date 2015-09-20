//
//  AKMultiTapDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

class AKMultiTapDelay: AKInstrument {

    /** initalize */
    convenience init(input: AKParameter, timesAndGainsDictionary: [Float : Float]) {
        self.init()

        var sum = input
        for (time, gain) in timesAndGainsDictionary {
            sum = sum + akp(gain) * AKDelay(input: input, delayTime: time)
        }
        
        output = AKAudioOutput(sum)
    }

}
