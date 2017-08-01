//
//  AUParamSlider.swift
//
//  Created by Ryan Francesconi on 6/28/17.
//  Copyright © 2017 Spongefork. All rights reserved.
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
        
        Swift.print("Creating slider: \(audioUnit.name) for \(param.displayName)")

        let titleField = createLabel(string: param.displayName)
        titleField.frame = NSMakeRect(0, 0, 120, 20)
        addSubview(titleField)
        
        slider.controlSize = .mini
        slider.target = self
        slider.action = #selector( self.handleAction(_:) )
        slider.frame = NSMakeRect(122, 2, 100, 20)
        addSubview(slider)
        
        slider.floatValue = param.value
        slider.maxValue = Double(param.maxValue)
        slider.minValue = Double(param.minValue)
        
        valueField = createLabel(string: String(param.value))
        valueField!.alignment = .left
        valueField!.frame = NSMakeRect(224, 2, 28, 20)
        addSubview(valueField!)
        
        if let unitName = param.unitName {
            let unitsField = createLabel(string: unitName)
            unitsField.alignment = .left
            unitsField.frame = NSMakeRect(249, 2, 40, 20)
            addSubview(unitsField)
        }
        
        frame = NSMakeRect(0, 0, 352, 20)
    }
    
    private func createLabel( string: String ) -> NSTextField {
        let tf = NSTextField()
        tf.isSelectable = false
        tf.isBordered = false
        tf.isEditable = false
        tf.alignment = .right
        tf.controlSize = .mini
        tf.font = NSFont.systemFont(ofSize: 8)
        tf.textColor = NSColor.white
        tf.backgroundColor = NSColor.white.withAlphaComponent(0)
        tf.stringValue = string
        return tf
    }
    
    func handleAction(_ sender: NSSlider) {
        guard sender == slider else { return }
        guard key != nil else { return }

        // AUParameter references aren't persistent, so we need to refetch them
        // addresses aren't guarenteed either, but this is working right now
        // unsure of the kvo style as i don't see the actual keys?
        if let p = audioUnit?.auAudioUnit.parameterTree?.parameter(withAddress: key!) {
            //Swift.print("p: \(p)")
            p.value = slider.floatValue
            if let field = valueField {
                field.stringValue = "\(round2(slider.floatValue, decimalPlaces: 3))"
            }
        }
    }
    
    func updateValue() {
        guard key != nil else { return }
        
        // AUParameter references aren't persistent, so we need to refetch them
        // addresses aren't guarenteed either, but this is working right now
        // unsure of the kvo style as i don't see the actual keys?
        if let p = audioUnit?.auAudioUnit.parameterTree?.parameter(withAddress: key!) {
            slider.floatValue = p.value
        }
    }
    
    private func round2(_ value: Float, decimalPlaces: Int) -> Float {
        let decimalValue = pow(10.0, Float(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }

    
}
