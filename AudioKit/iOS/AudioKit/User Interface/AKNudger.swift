//
//  AKNudger.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKNugder : AKStepper {
    override internal func setupButtons() {
        plusButton = AKButton(title: "+", callback: {_ in
            self.doPlusActionHit()
        })
        minusButton = AKButton(title: "-", callback: {_ in
            self.doMinusActionHit()
        })
        plusButton.buttonUpCallback = {_ in
            self.doPlusActionRelease()
        }
        minusButton.buttonUpCallback = {_ in
            self.doMinusActionRelease()
        }
    }
    private func doPlusActionHit() {
        value += increment
        valueLabel.text = "\(value)"
        callback(value)
    }
    private func doMinusActionHit() {
        value -= increment
        valueLabel.text = "\(value)"
        callback(value)
    }
    private func doPlusActionRelease() {
        value -= increment
        valueLabel.text = "\(value)"
        callback(value)
    }
    private func doMinusActionRelease() {
        value += increment
        valueLabel.text = "\(value)"
        callback(value)
    }
    override internal func checkValues() {
        //nothing to assert
    }
}
