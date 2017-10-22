//
//  AUParamSlider.swift
//
//  Created by Ryan Francesconi on 6/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation

class AudioUnitParamSlider: NSView {

    private var audioUnit: AVAudioUnit?
    private var key: AUParameterAddress?

    private var slider = NSSlider()
    private var valueField: NSTextField?

    convenience init( audioUnit: AVAudioUnit, param: AUParameter ) {
        self.init()

        self.audioUnit = audioUnit
        self.key = param.address

        let titleField = createLabel(string: param.displayName)
        titleField.frame = NSRect(x: 0, y: 0, width: 120, height: 20)
        addSubview(titleField)

        self.slider.action = #selector( self.handleAction(_:) )
        self.slider.target = self
        slider.frame = NSRect(x: 122, y: 2, width: 100, height: 20)
        addSubview(slider)

        valueField = createLabel(string: String(param.value))
        valueField!.alignment = .left
        valueField!.frame = NSRect(x: 224, y: 2, width: 28, height: 20)
        addSubview(valueField!)

        if let unitName = param.unitName {
            let unitsField = createLabel(string: unitName)
            unitsField.alignment = .left
            unitsField.frame = NSRect(x: 249, y: 2, width: 40, height: 20)
            addSubview(unitsField)
        }
        frame = NSRect(x: 0, y: 0, width: 352, height: 20)

        guard key != nil else { return }
        DispatchQueue.main.async {
            // need to refetch the param as it's dispatched later and the reference dies
            if let p = self.getParam(withAddress: self.key!) {
                self.slider.floatValue = p.value
                self.slider.maxValue = Double(p.maxValue)
                self.slider.minValue = Double(p.minValue)
                self.slider.controlSize = .mini
            }
        }
    }

    // AUParameter references aren't persistent, so we need to refetch them
    // addresses aren't guarenteed either, but well...
    public func getParam(withAddress theKey: AUParameterAddress) -> AUParameter? {
        return audioUnit?.auAudioUnit.parameterTree?.parameter(withAddress: theKey)
    }

    private func createLabel( string: String ) -> NSTextField {
        let tf = NSTextField()
        tf.isSelectable = false
        tf.isBordered = false
        tf.isEditable = false
        tf.alignment = .right
        tf.font = NSFont.systemFont(ofSize: 8)
        tf.textColor = NSColor.white
        tf.backgroundColor = NSColor.white.withAlphaComponent(0)
        tf.stringValue = string
        DispatchQueue.main.async {
            tf.controlSize = .mini
        }
        return tf
    }

    @objc func handleAction(_ sender: NSSlider) {
        guard sender == slider else { return }
        guard key != nil else { return }

        if let p = getParam(withAddress: key!) {
            //Swift.print("p: \(p)")
            p.value = slider.floatValue
            if let field = valueField {
                field.stringValue = "\(round2(slider.floatValue, decimalPlaces: 3))"
            }
        }
    }

    func updateValue() {
        guard key != nil else { return }
        if let p = getParam(withAddress: key!) {
            slider.floatValue = p.value
        }
    }

    private func round2(_ value: Float, decimalPlaces: Int) -> Float {
        let decimalValue = pow(10.0, Float(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }

}
