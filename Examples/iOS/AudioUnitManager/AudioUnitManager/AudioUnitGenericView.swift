//
//  AudioUnitGenericView.swift
//  AudioUnitManagerExample-iOS
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import AudioKitUI

/// Creates a simple list of parameters linked to sliders
class AudioUnitGenericView: UIView {

    convenience init(au: AVAudioUnit) {
        self.init()

        guard let tree = au.auAudioUnit.parameterTree else { return }

        var y = 5
        for param in tree.allParameters {
            let slider = AKSlider(property: param.displayName,
                                  value: Double(param.value),
                                  range: Double(param.minValue) ... Double(param.maxValue),
                                  format: "%0.1f",
                                  color: UIColor.darkGray,
                                  frame: CGRect(x: 20, y: y, width: 250, height: 50),
                                  callback: { (value) -> Void in

                // AUParameter references aren't persistent, so we need to refetch them
                // addresses aren't guarenteed either, but this is working right now
                if let p = au.auAudioUnit.parameterTree?.parameter(withAddress: param.address) {
                    p.value = AUValue(value)
                }

            })

            slider.textColor = UIColor.black
            slider.fontSize = 10
            slider.sliderBorderColor = UIColor.random()

            addSubview(slider)

            y += 50

        }

        self.frame = CGRect(x: 0, y: 0, width: 270, height: y)
    }

}
