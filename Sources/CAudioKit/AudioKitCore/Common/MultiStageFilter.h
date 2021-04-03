// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// MultiStageFilter implements a simple digital low-pass filter with dynamically
// adjustable cutoff frequency and resonance.
//
// Filter resonance is usually expressed in dB, but to avoid having to call expensive
// math functions like pow(), we use a linear value between 10.0 (-20 dB) and 0.1 (+20 dB)

#pragma once

#include "ResonantLowPassFilter.h"

namespace AudioKitCore
{

    struct MultiStageFilter
    {
        static constexpr int maxStages = 4;
        int stages;
        ResonantLowPassFilter stage[maxStages];

        MultiStageFilter();

        void init(double sampleRateHz);
        void updateSampleRate(double sampleRateHz);

        void setStages(int nStages);
        void setParameters(double newCutoffHz, double newResLinear);
        void setCutoff(double newCutoffHz);
        void setResonance(double newResLinear);
        
        float process(float sample);
    };

}
