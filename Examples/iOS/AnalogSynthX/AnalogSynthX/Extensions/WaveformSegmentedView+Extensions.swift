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
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_triangle_selected"),
                                         offSelectionImage: UIImage(named: "wave_triangle"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_square_selected"),
                                         offSelectionImage: UIImage(named: "wave_square"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_pulse_selected"),
                                         offSelectionImage: UIImage(named: "wave_pulse"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_saw_selected"),
                                         offSelectionImage: UIImage(named: "wave_saw"))
    }

    func addLfoWaveforms() {
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_sine_selected"),
                                         offSelectionImage: UIImage(named: "wave_sine"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_square_selected"),
                                         offSelectionImage: UIImage(named: "wave_square"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_upSaw_selected"),
                                         offSelectionImage: UIImage(named: "wave_upSaw"))
        let _ = self.addSegmentWithTitle("",
                                         onSelectionImage: UIImage(named: "wave_downSaw_selected"),
                                         offSelectionImage: UIImage(named: "wave_downSaw"))
    }
}
