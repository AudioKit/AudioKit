//
//  Fatten.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Fatten: AKNode {

    var time = 0.05 {
        didSet {
            output.parameters = [time, mix]
        }
    }
    var mix = 0.5 {
        didSet {
            output.parameters = [time, mix]
        }
    }

    private var output: AKOperationEffect

    init(_ input: AKNode) {

        let fattenTimeParameter = AKOperation.parameters(0)
        let fattenMixParameter = AKOperation.parameters(1)

        let fattenOperation = AKStereoOperation(
            "\(AKStereoOperation.input) dup \(1 - fattenMixParameter) * swap 0 \(fattenTimeParameter) 1.0 vdelay \(fattenMixParameter) * +")
        output = AKOperationEffect(input, stereoOperation: fattenOperation)
        super.init()
        self.avAudioNode = output.avAudioNode
        input.addConnectionPoint(self)

    }
}

