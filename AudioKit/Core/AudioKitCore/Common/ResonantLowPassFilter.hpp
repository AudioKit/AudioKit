// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// ResonantLowPassFilter implements a simple digital low-pass filter with dynamically
// adjustable cutoff frequency and resonance.
//
// Filter resonance is usually expressed in dB, but to avoid having to call expensive
// math functions like pow(), we use a linear value between 10.0 (-20 dB) and 0.1 (+20 dB)

#pragma once

namespace AudioKitCore
{

    struct ResonantLowPassFilter
    {
        // coefficients
        double a0, a1, a2, b1, b2;
        
        // state
        double x1, x2, y1, y2;
        
        // misc
        double sampleRateHz, mLastCutoffHz, mLastResLinear;
        
        ResonantLowPassFilter();
        
        void init(double sampleRateHz);
        void updateSampleRate(double sampleRate) { sampleRateHz = sampleRate; }
        
        void setParameters(double newCutoffHz, double newResLinear);
        void setCutoff(double newCutoffHz) { setParameters(newCutoffHz, mLastResLinear); }
        void setResonance(double newResLinear) { setParameters(mLastCutoffHz, newResLinear); }
        
        void process(const float *inSourceP, float *inDestP, int inFramesToProcess);

        inline float process(float inputSample)
        {
            float outputSample = (float)(a0*inputSample + a1*x1 + a2*x2 - b1*y1 - b2*y2);

            x2 = x1;
            x1 = inputSample;
            y2 = y1;
            y1 = outputSample;

            return outputSample;
        }

    };

}
