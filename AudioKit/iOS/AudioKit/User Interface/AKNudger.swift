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
        plusButton.releaseCallback = {_ in
            self.doPlusActionRelease()
        }
        minusButton.releaseCallback = {_ in
            self.doMinusActionRelease()
        }
    }
    private func doPlusActionHit() {
        if increment == 0 {
            value = maximum
        }
    }
    private func doPlusActionRelease() {
        if increment == 0 {
            value = originalValue
        }
    }
    private func doMinusActionHit() {
        if increment == 0 {
            value = minimum
        }
    }
    private func doMinusActionRelease() {
        if increment == 0 {
            value = originalValue
        }
    }
    override internal func checkValues() {
        assert(minimum < maximum)
        originalValue = value
        startTimers()
    }
    private var frameRate = TimeInterval(1.0 / 60.0)
    private var animationTimer: Timer?
    private var lastValue: Double = 0
    private func animateValue(){
        if !plusButton.isPressed && !minusButton.isPressed{
            if value >~ originalValue{
                value -= increment
            }else if value <~ originalValue {
                value += increment
            }
        }else if plusButton.isPressed{
            if value <~ maximum {
                value += increment
            }
        }else if minusButton.isPressed{
            if value >~ minimum{
                value -= increment
            }
        }
        if value >~ maximum { value = maximum }
        if value <~ minimum { value = minimum }
        callbackOnChange()
        lastValue = value
    }
    private func callbackOnChange(){
        if lastValue != value{
            callback(value)
        }
    }
    private func startTimerIfNeeded(timer: Timer?, callback: @escaping (Timer) -> Void ) -> Timer?{
        if timer != nil, timer!.isValid{
            return nil
        }
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: self.frameRate, repeats: true,
                                        block: callback)
        } else {
            return nil
        }
    }
    private func startTimers(){
        DispatchQueue.main.async {
            if let timer = self.startTimerIfNeeded(timer: self.animationTimer,
                                                   callback: {_ in self.animateValue() }){
                self.animationTimer = timer
            }
        }
    }
    open func setStable(value: Double) {
        print("old values lo \(minimum) med \(originalValue) hi \(maximum)")
        let diff = value - originalValue
        originalValue = value
        maximum += diff
        minimum += diff
        print("set new values to lo \(minimum) med \(originalValue) hi \(maximum)")
    }
}
