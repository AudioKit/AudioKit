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
        if slewRate == 0 {
            value += increment
        }else{
            startPlusTimer()
        }
    }
    private func doPlusActionRelease() {
        if slewRate == 0 {
            value -= increment
        }
    }
    private func doMinusActionHit() {
        if slewRate == 0 {
            value -= increment
        }else{
            startMinusTimer()
        }
    }
    private func doMinusActionRelease() {
        if slewRate == 0 {
            value += increment
        }
    }
    override internal func checkValues() {
        //nothing to assert
        originalValue = value
        maximum = value + increment
        minimum = value - increment
    }
    var slewRate = 0.01
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
    private var rate: Double{
        return increment * slewRate
    }
    private var lastValue: Double = 0
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
        callbackOnChange()
        lastValue = value
    }
    private func animateMinusValue(){
        if minusButton.isPressed{
            if value - rate > minimum{
                value -= rate
            }
        }else{
            if value + rate <= originalValue {
                value += rate
            }
        }
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
}
