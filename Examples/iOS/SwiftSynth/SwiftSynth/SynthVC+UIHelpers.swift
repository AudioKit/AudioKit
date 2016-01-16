//
//  SynthVC+UIHelpers.swift
//  SwiftSynth
//
//  Created by Matthew Fecher on 1/15/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension SynthViewController {
    
    //*****************************************************************
    // MARK: - Set Delegates
    //*****************************************************************
    
    func setDelegates() {
        oscMixKnob.delegate = self
        cutoffKnob.delegate = self
        rezKnob.delegate = self
        osc1SemitonesKnob.delegate = self
        osc2SemitonesKnob.delegate = self
        osc2DetuneKnob.delegate = self
        lfoAmtKnob.delegate = self
        lfoRateKnob.delegate = self
        crushAmtKnob.delegate = self
        delayTimeKnob.delegate = self
        delayMixKnob.delegate = self
        reverbAmtKnob.delegate = self
        reverbMixKnob.delegate = self
        subMixKnob.delegate = self
        fmMixKnob.delegate = self
        fmModKnob.delegate = self
        pwmKnob.delegate = self
        noiseMixKnob.delegate = self
        masterVolKnob.delegate = self
        attackSlider.delegate = self
        decaySlider.delegate = self
        sustainSlider.delegate = self
        releaseSlider.delegate = self
    }

    //*****************************************************************
    // MARK: - Synth UI Helpers
    //*****************************************************************
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
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