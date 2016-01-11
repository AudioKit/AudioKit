//
//  MultiDelay.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

struct MultiDelay {
    
    var output = AKMixer()
    
    func multitapDelay(input: AKNode, times: [Double], gains: [Double]) -> AKMixer {
        let mix = AKMixer(input)
        zip(times, gains).forEach { (time, gain) -> () in
            let delay = AKDelay(input, time: time, feedback: 0.0, dryWetMix: 100)
            mix.connect(AKBooster(delay, gain: gain))
        }
        return mix
    }
    
    init(_ input: AKNode) {
        // Delay Properties
        let delayTime = 1.0 // Seconds
        let delayMix  = 0.4 // 0 (dry) - 1 (wet)
        let gains = [0.5, 0.25, 0.15].map { g -> Double in g * delayMix }
        
        // Delay Definition
        let leftDelay = multitapDelay(input,
            times: [1.5, 2.5, 3.5].map { t -> Double in t * delayTime },
            gains: gains)
        let rightDelay = multitapDelay(input,
            times: [1, 2, 3].map { t -> Double in t * delayTime },
            gains: gains)
        let delayPannedLeft = AKPanner(leftDelay, pan: -1)
        let delayPannedRight = AKPanner(rightDelay, pan: 1)
        
        output = AKMixer(delayPannedLeft, delayPannedRight)
    }
}