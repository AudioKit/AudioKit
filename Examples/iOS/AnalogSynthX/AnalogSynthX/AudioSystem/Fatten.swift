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

    init(_ input: AKNode) {
        let delay = AKDelay.init(input, time: 0.05, dryWetMix: 0.5)
        let pannedDelay = AKPanner(delay, pan: 1)
        let pannedSource = AKPanner(input, pan: -1)
        let wet = AKMixer(pannedDelay, pannedSource)
        dryWetMix = AKDryWetMixer(input, wet, balance: 0)
        super.init()
        self.avAudioNode = dryWetMix.avAudioNode
        input.addConnectionPoint(self)
    }
}
