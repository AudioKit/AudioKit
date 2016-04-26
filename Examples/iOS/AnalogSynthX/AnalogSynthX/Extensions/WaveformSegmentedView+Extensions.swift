//
//  SMSegmentView+Extensions.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension WaveformSegmentedView {

    func addOscWaveforms() {
        // Add segments
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_triangle_selected"), offSelectionImage: UIImage(named: "wave_triangle"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_square_selected"), offSelectionImage: UIImage(named: "wave_square"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_pulse_selected"), offSelectionImage: UIImage(named: "wave_pulse"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_saw_selected"), offSelectionImage: UIImage(named: "wave_saw"))
    }

    func addLfoWaveforms() {
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_sine_selected"), offSelectionImage: UIImage(named: "wave_sine"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_square_selected"), offSelectionImage: UIImage(named: "wave_square"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_upSaw_selected"), offSelectionImage: UIImage(named: "wave_upSaw"))
        self.addSegmentWithTitle("", onSelectionImage: UIImage(named: "wave_downSaw_selected"), offSelectionImage: UIImage(named: "wave_downSaw"))
    }
}
