//
//  Knob+Touches.swift
//  Swift Synth
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

extension Knob {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            lastX = touchPoint.x
            lastY = touchPoint.y
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            setPercentagesWithTouchPoint(touchPoint)
        }
    }

}
