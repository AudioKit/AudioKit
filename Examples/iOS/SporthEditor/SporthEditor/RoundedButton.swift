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

    func buttonDown() {
        self.backgroundColor = #colorLiteral(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
    }

    func buttonUp() {
        self.backgroundColor = #colorLiteral(red: 31 / 255, green: 31 / 255, blue: 31 / 255, alpha: 1)
    }
}
