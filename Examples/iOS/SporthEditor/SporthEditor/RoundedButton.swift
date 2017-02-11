//
//  RoundedButton.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
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
        self.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }

    func buttonUp() {
         self.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
    }
}
