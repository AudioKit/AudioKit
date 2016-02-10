//
//  Fatten.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class Fatten: AKNode {

    var output: AKOperationEffect

    init(_ input: AKNode) {

        let fattenTimeParameter = 0.05

        let fattenOperation = AKStereoOperation(
            "\(AKStereoOperation.input) dup 0.5 * swap 0 \(fattenTimeParameter) 1.0 vdelay 0.5 * +")
        output = AKOperationEffect(input, stereoOperation: fattenOperation)
        super.init()
        self.avAudioNode = output.avAudioNode
        input.addConnectionPoint(self)

    }
}

