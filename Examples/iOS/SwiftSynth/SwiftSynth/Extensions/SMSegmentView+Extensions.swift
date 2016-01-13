//
//  SMSegmentView+Extensions.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension SMSegmentView {
    
    func createOscSegmentView(tag: Int) {
        self.setOscColors()
        self.tag = tag
        self.addOscWaveforms()
    }
    
    func createLfoSegmentView(tag: Int) {
        self.setOscColors()
        self.tag = tag
        self.addLfoWaveforms()
    }
    
    func setOscColors() {
        separatorColour = UIColor.clearColor()
        separatorWidth = 0.5
        segmentOnSelectionColour = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        segmentOffSelectionColour = UIColor.clearColor()
        segmentVerticalMargin = CGFloat(10.0)
    }
    
    func addOscWaveforms() {
        // Add segments
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_saw_selected"), offSelectionImage: UIImage(named: "wave_saw"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_square_selected"), offSelectionImage: UIImage(named: "wave_square"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_sine_selected"), offSelectionImage: UIImage(named: "wave_sine"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_triangle_selected"), offSelectionImage: UIImage(named: "wave_triangle"))
    }
    
    func addLfoWaveforms() {
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_sine_selected"), offSelectionImage: UIImage(named: "wave_sine"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_square_selected"), offSelectionImage: UIImage(named: "wave_square"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_triangle_selected"), offSelectionImage: UIImage(named: "wave_triangle"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_upSaw_selected"), offSelectionImage: UIImage(named: "wave_upSaw"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_downSaw_selected"), offSelectionImage: UIImage(named: "wave_downSaw"))
    }
}