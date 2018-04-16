//
//  CGFloat+Extensions.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

extension CGFloat {

    // Formatted percentage string e.g. 0.55 -> 55%
    var percentageString: String {
        return "\(Int(100 * self))%"
    }

}
