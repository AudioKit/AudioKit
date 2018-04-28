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
//        value += increment
        startPlusTimer()
        callback(value)
    }
    private func doPlusActionRelease() {
        //        value -= increment
        callback(value)
    }
    private func doMinusActionHit() {
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
        originalValue = value
        maximum = value + increment
        minimum = value - increment
    }
    private var slewRate = 0.01
    private var frameRate = TimeInterval(1.0 / 60.0)
    private var plusButtonTimer: Timer?
    private var minusButtonTimer: Timer?
    private func startPlusTimer(){
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                self.plusButtonTimer = Timer.scheduledTimer(withTimeInterval: self.frameRate, repeats: true, block: {_ in
                        self.animatePlusValue()
                })
                self.plusButtonTimer?.fire()
            } else {
                // Fallback on earlier versions
                
            }
        }
    }
    private var rate: Double{
        return increment * slewRate
    }
    private func animatePlusValue(){
        if plusButton.isPressed{
            if value + rate < maximum {
                value += rate
            }
        }else{
            if value - rate >= originalValue{
                value -= rate
            }
        }
    }
    private func animateMinusValue(){
        if minusButton.isPressed{
            if value >= originalValue - increment{
                value -= slewRate
            }
        }else{
            if value <= originalValue{
                value += slewRate
            }
        }
    }
}
