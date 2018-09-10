//
//  EnsembleOscillator.hpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-02.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#include "FunctionTable.hpp"
#include "WaveStack.hpp"

namespace AudioKitCore
{

    // An EnsembleOscillator is WaveStack-based oscillator which provides an "ensemble" effect
    // based on up to 10 simultaneous waveform-readout "phases" differing slightly in frequency
    // (pitch spread) and left/right balance (pan spread).
    // If the phases variable is set to 0, the oscillator is disabled. If set to 1, the result
    // is a conventional, single-phase oscillator.

    struct EnsembleOscillator
    {
        double sampleRateHz;            // current output sample rate
        WaveStack *pWaveStack;          // pointer to shared WaveStack

        int phases;                     // number of unison/ensemble phases
        float freqSpread;               // frequency difference between phases, cents

        // per-phase variables
        static constexpr int maxPhases = 10;    // maximum number of phases 10
        int octave[maxPhases];          // WaveStack octave used by this phase
        float phase[maxPhases];         // Fraction of the way through waveform
        float phaseDelta[maxPhases];    // normalized frequency: cycles per sample
        float leftGain[maxPhases];      // left gain
        float rightGain[maxPhases];     // right gain

        // performance variables
        float phaseDeltaMul;            // phaseDelta multiplier for pitchbend, vibrato

        EnsembleOscillator() : phases(1), freqSpread(0.0f) {}
        void init(double sampleRate, WaveStack *pStack);
        void setPhases(int nPhases);
        void setFreqSpread(float fSpread) { freqSpread = fSpread; }
        void setPanSpread(float fSpread);   // arg is a fraction: 0 = no spread, 1 = max spread
        void setFrequency(float frequency);

        float getSample();
        void getSamples(float *pLeft, float *pRight, float gain);
    };

}
