//
//  Conductor.swift
//  AUV3Example
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

class Conductor {
    var osc = TestOscillator()

    func start() {
        try? AudioKit.start()
    }

    func setupRoute() {
        osc.setupRoute()
        AudioKit.output = osc.output
    }
}
