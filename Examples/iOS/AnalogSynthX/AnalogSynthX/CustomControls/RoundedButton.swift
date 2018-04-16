//
//  RoundedButton.swift
//  Swift Synth
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright (c) 2016 AudioKit. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        clipsToBounds = true
        layer.cornerRadius = 6
    }
}
