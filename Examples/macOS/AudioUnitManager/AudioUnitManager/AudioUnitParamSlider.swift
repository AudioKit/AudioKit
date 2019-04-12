//
//  AUParamSlider.swift
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation
import Cocoa

class AudioUnitParamSlider: NSView {
    private var audioUnit: AVAudioUnit?
    private var key: AUParameterAddress?

    private var slider = NSSlider()
    private var valueField: NSTextField?

    convenience init(audioUnit: AVAudioUnit, param: AUParameter) {
        self.init()

        self.audioUnit = audioUnit
        key = param.address

        let titleField = createLabel(string: param.displayName)
        titleField.frame = NSRect(x: 0, y: 0, width: 120, height: 20)
        addSubview(titleField)

        slider.action = #selector(handleAction(_:))
        slider.target = self
        slider.frame = NSRect(x: 122, y: 2, width: 100, height: 20)
        addSubview(slider)

        let field = createLabel(string: String(param.value))
        field.alignment = .left
        field.frame = NSRect(x: 224, y: 2, width: 28, height: 20)
        addSubview(field)
        valueField = field

        if let unitName = param.unitName {
            let unitsField = createLabel(string: unitName)
            unitsField.alignment = .left
            unitsField.frame = NSRect(x: 249, y: 2, width: 40, height: 20)
            addSubview(unitsField)
        }
        frame = NSRect(x: 0, y: 0, width: 352, height: 20)

        guard let key = key else { return }

        DispatchQueue.main.async {
            // need to refetch the param as it's dispatched later and the reference dies
            if let p = self.getParam(withAddress: key) {
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

    private func createLabel(string: String) -> NSTextField {
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
        guard let key = key else { return }

        if let p = getParam(withAddress: key) {
            // AKLog("p: \(p)")
            p.value = slider.floatValue
            if let field = valueField {
                field.stringValue = "\(round2(slider.floatValue, decimalPlaces: 3))"
            }
        }
    }

    func updateValue() {
        guard let key = key else { return }
        if let p = getParam(withAddress: key) {
            slider.floatValue = p.value
        }
    }

    private func round2(_ value: Float, decimalPlaces: Int) -> Float {
        let decimalValue = pow(10.0, Float(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }
}
