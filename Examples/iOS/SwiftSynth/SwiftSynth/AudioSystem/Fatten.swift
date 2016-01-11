//
//  Fatten.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

struct Fatten {
    
    var output: AKOperationEffect?
    
    var parameters: [Double] = [0.05, 0.5] {
        didSet {
            output!.parameters = parameters
        }
    }
    
    init(_ input: AKNode) {

        let fattenTimeParameter = AKOperation.parameters(0)
        let fattenMixParameter = AKOperation.parameters(1)
        
        let fattenOperation = AKStereoOperation(
            "\(AKStereoOperation.input) dup \(1 - fattenMixParameter) * swap 0 \(fattenTimeParameter) 1.0 vdelay \(fattenMixParameter) * +")
        output = AKOperationEffect(input, stereoOperation: fattenOperation)
    }
}
