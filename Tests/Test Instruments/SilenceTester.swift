//
//  TestSilence.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class SilenceTester : AKInstrument {
    
    override init() {
        super.init()
        output = 0.ak * AKOscillator()
    }
}