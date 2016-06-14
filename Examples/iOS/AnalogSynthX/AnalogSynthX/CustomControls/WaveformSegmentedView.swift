//
//  WaveformSegmentedView.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher on 1/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

class WaveformSegmentedView: SMSegmentView {

    func setOscColors() {
        separatorColour = UIColor.clear()
        separatorWidth = 0.5
        segmentOnSelectionColour = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        segmentOffSelectionColour = UIColor.clear()
        segmentVerticalMargin = CGFloat(10.0)
    }

}
