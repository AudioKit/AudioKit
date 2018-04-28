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
        if increment == 0 {
            value = maximum
        }else{
            print("animating \(value)")
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
        }else{
            print("animating \(value)")
        }
    }
    private func doMinusActionRelease() {
        if increment == 0 {
            value = originalValue
        }
    }
    override internal func checkValues() {
        //nothing to assert
        assert(minimum < maximum)
        originalValue = value
        startTimers()
    }
    private var frameRate = TimeInterval(1.0 / 60.0)
    private var plusButtonTimer: Timer?
    private var minusButtonTimer: Timer?
    private func startPlusTimer(){
        DispatchQueue.main.async {
            if let timer = self.startTimerIfNeeded(timer: self.plusButtonTimer,
                                                   callback: {_ in self.animatePlusValue() }){
                self.plusButtonTimer = timer
            }
        }
    }
    private func startMinusTimer(){
        DispatchQueue.main.async {
            if let timer = self.startTimerIfNeeded(timer: self.minusButtonTimer,
                                                   callback: {_ in self.animateMinusValue() }){
                self.minusButtonTimer = timer
            }
        }
    }
    private var lastValue: Double = 0
    private func animatePlusValue(){
        if plusButton.isPressed{
            if value + increment < maximum + increment {
                value += increment
            }
        }else{
            if value - increment >= originalValue - increment{
                value -= increment
            }
        }
        if value > maximum { value = maximum }
        callbackOnChange()
        lastValue = value
    }
    private func animateMinusValue(){
        if minusButton.isPressed{
            if value - increment >= minimum - increment{
                value -= increment
            }
        }else{
            if value + increment <= originalValue + increment {
                value += increment
            }
        }
        if value < minimum { value = minimum }
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
        startPlusTimer()
        startMinusTimer()
    }
}
