//
//  String+RandomGreeting.swift
//  SwiftSynth
//
//  Created by Matthew Fecher on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension String {
    public static func randomGreeting() -> String {
        let randomInt = floor(Double.random(min: 0, max: 4))
        switch randomInt {
        case 0:
            return "Welcome, can synth be love?"
        case 1:
            return "Affirmative, Dave. I read you."
        case 2:
            return "Eat. Sleep. Synth. Repeat."
        case 3:
            return "Welcome to Swift Synth!"
        default:
            return "Welcome"
        }
    }
}