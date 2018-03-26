//
//  String+RandomGreeting.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension String {
    public static func randomGreeting() -> String {
        let randomInt = floor(Double.random(min: 0, max: 4))
        switch randomInt {
        case 0:
            return "Plug in headphones for best sound."
        case 1:
            return "Affirmative, Dave. I read you."
        case 2:
            return "Eat. Swift. Synth. Repeat."
        case 3:
            return "Welcome!"
        default:
            return "Welcome"
        }
    }
}
