//
//  AKPresetTester.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/20/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKPresetTester : AKInstrument {
    convenience init(_ preset: AKParameter) {
        self.init()
        
        output = AKAudioOutput(preset)
    }
}