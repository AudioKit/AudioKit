//
//  AKNudger.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

@IBDesignable open class AKNudger: AKStepper {
    open var linear = true
    private func doPlusActionHit() {
        if increment == 0 {
            currentValue = maximum
        }
        touchBeganCallback()
    }
    private func doPlusActionRelease() {
        if increment == 0 {
            currentValue = originalValue
        }
        touchEndedCallback()
    }
    private func doMinusActionHit() {
        if increment == 0 {
            currentValue = minimum
        }
        touchBeganCallback()
    }
    private func doMinusActionRelease() {
        if increment == 0 {
            currentValue = originalValue
        }
        touchEndedCallback()
    }
    override internal func checkValues() {
        assert(minimum < maximum)
        originalValue = currentValue
        startTimers()
    }
    private var frameRate = TimeInterval(1.0 / 50.0)
    private var animationTimer: Timer?
    private var lastValue: Double = 0
    private func animateValue() {
        if plusButton.isPressed == false {
            if plusHeldCounter > 0 {
                plusHeldCounter -= 1
            }
        } else {
            if plusHeldCounter < maxPlusCounter {
                plusHeldCounter += 1
            }
        }
        if minusButton.isPressed == false {
            if minusHeldCounter > 0 {
                minusHeldCounter -= 1
            }
        } else {
            if minusHeldCounter < maxMinusCounter {
                minusHeldCounter += 1
            }
        }
        let addValue = Double(increment * plusHeldCounter) *
            (linear ? 1 : Double(plusHeldCounter) / Double(maxPlusCounter))
        let subValue = Double(increment * minusHeldCounter) *
            (linear ? 1 : Double(minusHeldCounter) / Double(maxMinusCounter))
        currentValue = originalValue + addValue - subValue
        callbackOnChange()
        lastValue = currentValue
    }
    private func callbackOnChange() {
        if lastValue != currentValue {
            callback(currentValue)
        }
    }
    private var plusHeldCounter: Int = 0
    private var minusHeldCounter: Int = 0
    private var maxPlusCounter: Int {
        return Int(abs((maximum - originalValue) / increment))
    }
    private var maxMinusCounter: Int {
        return Int(abs((minimum - originalValue) / increment))
    }
    private func startTimerIfNeeded(timer: Timer?, callback: @escaping (Timer) -> Void ) -> Timer? {
        if let timer = timer {
            if timer.isValid {
                return nil
            }
        }
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: self.frameRate, repeats: true,
                                        block: callback)
        } else {
            return nil
        }
    }
    private func startTimers() {
        DispatchQueue.main.async {
            if let timer = self.startTimerIfNeeded(timer: self.animationTimer,
                                                   callback: { _ in self.animateValue() }) {
                self.animationTimer = timer
            }
        }
    }
    open func setStable(value: Double) {
        let diff = value - originalValue
        originalValue = value
        maximum += diff
        minimum += diff
    }
    override internal func setupButtons(frame: CGRect) {
        plusButton = AKButton(title: "+", frame: frame, callback: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doPlusActionHit()
            strongSelf.touchBeganCallback()
        })
        minusButton = AKButton(title: "-", frame: frame, callback: { [weak self]  _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doMinusActionHit()
            strongSelf.touchBeganCallback()
        })
        plusButton.releaseCallback = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doPlusActionRelease()
            strongSelf.touchEndedCallback()
        }
        minusButton.releaseCallback = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doMinusActionRelease()
            strongSelf.touchEndedCallback()
        }
        plusButton.font = buttonFont ?? UIFont.systemFont(ofSize: 12)
        minusButton.font = buttonFont ?? UIFont.systemFont(ofSize: 12)
        plusButton.borderWidth = buttonBorderWidth
        minusButton.borderWidth = buttonBorderWidth
        addToStackIfPossible(view: minusButton, stack: buttons)
        addToStackIfPossible(view: plusButton, stack: buttons)
        self.addSubview(buttons)
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override init(text: String,
                         value: Double,
                         minimum: Double,
                         maximum: Double,
                         increment: Double,
                         frame: CGRect,
                         showsValue: Bool = true,
                         callback: @escaping (Double) -> Void) {
        super.init(text: text,
                   value: value,
                   minimum: minimum,
                   maximum: maximum,
                   increment: increment,
                   frame: frame,
                   showsValue: showsValue,
                   callback: callback)
    }
}
