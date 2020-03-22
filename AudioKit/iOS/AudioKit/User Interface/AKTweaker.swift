//
//  AKTweaker.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

@IBDesignable open class AKTweaker: AKCoarseFineSlider {

    var nudger: AKNudger!
    public override func setStable(value: Double) {
        nudger.setStable(value: value)
        coarseStepper.currentValue = value
        fineStepper.currentValue = value
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        name = "Tweaker"
    }
    override internal func genSubViews() {
        coarseStepper = AKStepper(text: "Coarse",
                                  value: currentValue,
                                  minimum: minimum,
                                  maximum: maximum,
                                  increment: 0.01,
                                  frame: frame,
                                  showsValue: false,
                                  callback: { _ in })
        fineStepper = AKStepper(text: "Fine",
                                value: currentValue,
                                minimum: minimum,
                                maximum: maximum,
                                increment: 0.001,
                                frame: frame,
                                showsValue: false,
                                callback: { _ in })
        nudger = AKNudger(text: "Nudge", value: currentValue, minimum: minimum, maximum: maximum,
                          increment: 0.066_6, frame: frame, showsValue: false, callback: { _ in })
        slider = AKSlider(property: "",
                          value: currentValue,
                          range: minimum ... maximum,
                          taper: 1.0, format: "",
                          color: AKStylist.sharedInstance.nextColor,
                          frame: frame,
                          callback: { _ in })
        coarseStepper.touchBeganCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchBeganCallback()
        }
        coarseStepper.touchEndedCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        fineStepper.touchBeganCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchBeganCallback()
        }
        fineStepper.touchEndedCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        slider.touchBeganCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchBeganCallback()
        }
        slider.touchEndedCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        coarseStepper.backgroundColor = .clear
        fineStepper.backgroundColor = .clear
        coarseStepper.showsValue = false
        fineStepper.showsValue = false
        coarseStepper.buttonBorderWidth = buttonBorderWidth
        fineStepper.buttonBorderWidth = buttonBorderWidth

        valueLabel = UILabel(frame: CGRect(x: frame.origin.x,
                                           y: frame.origin.y,
                                           width: frame.width,
                                           height: frame.height * 0.15))

        nameLabel = UILabel(frame: CGRect(x: frame.origin.x,
                                          y: frame.origin.y,
                                          width: frame.width,
                                          height: frame.height * 0.15))
        buttons = UIStackView(frame: CGRect(x: frame.origin.x,
                                            y: frame.origin.y,
                                            width: frame.width,
                                            height: frame.height * 0.7))

        coarseStepper.callback = { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.callback(value)
            strongSelf.currentValue = value
            strongSelf.fineStepper.currentValue = value
            strongSelf.nudger.setStable(value: value)
            strongSelf.slider.value = value
        }
        fineStepper.callback = { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.callback(value)
            strongSelf.currentValue = value
            strongSelf.coarseStepper.currentValue = value
            strongSelf.nudger.setStable(value: value)
            strongSelf.slider.value = value
        }
        slider.callback = { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.callback(value)
            strongSelf.currentValue = value
            strongSelf.coarseStepper.currentValue = value
            strongSelf.fineStepper.currentValue = value
            strongSelf.nudger.setStable(value: value)
        }
        nudger.linear = false
        nudger.callback = { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            strongSelf.callback(value)
            strongSelf.currentValue = value
            strongSelf.slider.value = value
        }
        nudger.touchBeganCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchBeganCallback()
        }
        nudger.touchEndedCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        nudger.backgroundColor = .clear
        nudger.showsValue = false
        super.setupFonts()
        nudger.labelFont = buttonLabelFont
        nudger.buttonFont = buttonFont
        nudger.buttonBorderWidth = buttonBorderWidth

        self.addSubview(nameLabel)
        self.addSubview(valueLabel)
        self.addSubview(slider)
        self.addSubview(buttons)
        addToStackIfPossible(view: coarseStepper, stack: buttons)
        addToStackIfPossible(view: fineStepper, stack: buttons)
        addToStackIfPossible(view: nudger, stack: buttons)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = "Tweaker"
    }
}
