//
//  SynthViewController+UIHelpers.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher on 1/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension SynthViewController {

    //*****************************************************************
    // MARK: - Synth UI Helpers
    //*****************************************************************

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func openURL(url: String) {
        guard let url = NSURL(string: url) else {
            return
        }
        UIApplication.sharedApplication().openURL(url)
    }

    func cutoffFreqFromValue(value: Double) -> Double {
        // Logarithmic scale: knobvalue to frequency
        let scaledValue = Double.scaleRangeLog(value, rangeMin: 30, rangeMax: 7000)
        return scaledValue * 4
    }
    
    func crusherFreqFromValue(value: Double) -> Double {
        // Logarithmic scale: reverse knobvalue to frequency
        let value = 1 - value
        let scaledValue = Double.scaleRangeLog(value, rangeMin: 50, rangeMax: 8000)
        return scaledValue
    }

    //*****************************************************************
    // MARK: - SegmentViews
    //*****************************************************************

    func createWaveFormSegmentViews() {
        setupOscSegmentView(8,   y: 75.0, width: 195, height: 46.0, tag: ControlTag.Vco1Waveform.rawValue, type: 0)
        setupOscSegmentView(212, y: 75.0, width: 226, height: 46.0, tag: ControlTag.Vco2Waveform.rawValue, type: 0)
        setupOscSegmentView(10,  y: 377,  width: 255, height: 46.0, tag: ControlTag.LfoWaveform.rawValue,  type: 1)
    }

    func setupOscSegmentView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, tag: Int, type: Int) {
        let segmentFrame = CGRect(x: x, y: y, width: width, height: height)
        let segmentView = WaveformSegmentedView(frame: segmentFrame)
        segmentView.setOscColors()

        if type == 0 {
            segmentView.addOscWaveforms()
        } else {
            segmentView.addLfoWaveforms()
        }

        segmentView.delegate = self
        segmentView.tag = tag

        // Set segment with index 0 as selected by default
        segmentView.selectSegmentAtIndex(0)
        self.view.addSubview(segmentView)
    }

}