//
//  Fatten.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Fatten: AKNode {
    var dryWetMix: AKDryWetMixer
    var delay: AKDelay
    var pannedDelay: AKPanner
    var pannedSource: AKPanner
    var wet: AKMixer

    init(_ input: AKNode) {
        delay = AKDelay(input, time: 0.05, dryWetMix: 0.5)
        pannedDelay = AKPanner(delay, pan: 1)
        pannedSource = AKPanner(input, pan: -1)
        wet = AKMixer(pannedDelay, pannedSource)
        dryWetMix = AKDryWetMixer(input, wet, balance: 0)
        super.init()
        self.avAudioNode = dryWetMix.avAudioNode
        input.addConnectionPoint(self)
    }
}
