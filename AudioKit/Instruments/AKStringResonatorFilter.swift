//
//  AKStringResonatorFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKStringResonatorFilter : AKInstrument {

    var filter: AKStringResonator?
    
    /** initalize */
    convenience init(input: AKParameter) {
        self.init()
        filter = AKStringResonator(input: input)
        output = AKAudioOutput(input: filter!)
    }
}