//
//  ResonantLowPassFilter.hpp
//  AudioKit Core
//
//  Created by Shane Dunne based on sample code by Apple, Inc.
//  Copyright © 2018 AudioKit and Apple.
//
// ResonantLowPassFilter implements a simple digital low-pass filter with dynamically
// adjustable cutoff frequency and resonance. The code is derived from Apple's old
// AUv2 filter demo, and based on careful reading, I am confident this usage is
// consistent with the license text Apple provided with the original demo code.

#pragma once

namespace AudioKitCore
{

    struct ResonantLowPassFilter
    {
        // filter coefficients
        double mA0, mA1, mA2, mB1, mB2;
        
        // filter state
        double mX1, mX2, mY1, mY2;
        
        // misc
        double sampleRateHz, mLastCutoffHz, mLastResonanceDb;
        
        ResonantLowPassFilter();
        
        void init(double sampleRateHz);
        void updateSampleRate(double sampleRateHz) { this->sampleRateHz = sampleRateHz; }
        
        void setParams(double newCutoffHz, double newResonanceDb);
        void setCutoff(double newCutoffHz) { setParams(newCutoffHz, mLastResonanceDb); }
        void setResonance(double newResonanceDb) { setParams(mLastCutoffHz, newResonanceDb); }
        
        void process(const float *inSourceP, float *inDestP, int inFramesToProcess);
        
        inline float process(float inputSample)
        {
            float outputSample = (float)(mA0*inputSample + mA1*mX1 + mA2*mX2 - mB1*mY1 - mB2*mY2);
            
            mX2 = mX1;
            mX1 = inputSample;
            mY2 = mY1;
            mY1 = outputSample;
            
            return outputSample;
        }
    };

}
