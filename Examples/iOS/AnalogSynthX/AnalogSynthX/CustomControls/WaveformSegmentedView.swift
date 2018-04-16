//
//  WaveformSegmentedView.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

class WaveformSegmentedView: SMSegmentView {

    func setOscColors() {
        separatorColour = .clear
        separatorWidth = 0.5
        segmentOnSelectionColour = #colorLiteral(red: 34.0 / 255.0,
                                                 green: 34.0 / 255.0,
                                                 blue: 34.0 / 255.0,
                                                 alpha: 1.0)
        segmentOffSelectionColour = .clear
        segmentVerticalMargin = CGFloat(10.0)
    }

}
