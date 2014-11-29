//
//  ToneGenerator.swift
//  SwiftKeyboard
//
//  Created by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

class ToneGenerator: AKInstrument {

    // Instrument Properties
    var pan  = AKInstrumentProperty(value: 0.0, minimum: 0.0, maximum: 1.0)

    override init() {
        super.init()

        // Instrument Properties
        addProperty(pan)

        // Note Properties
        note = ToneGeneratorNote()

        // Place instrument code here
    }
}

class ToneGeneratorNote: AKInstrumentNote {

    // Place Note Properties here

    override init() {
        super.init()

        // Place instrument code here
    }
}
