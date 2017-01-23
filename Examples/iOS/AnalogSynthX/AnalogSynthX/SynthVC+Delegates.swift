//
//  SynthVC+Delegates.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher on 1/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

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
        morphKnob.delegate = self
        noiseMixKnob.delegate = self
        masterVolKnob.delegate = self
        attackSlider.delegate = self
        decaySlider.delegate = self
        sustainSlider.delegate = self
        releaseSlider.delegate = self
    }
}
