// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// ResonantLowPassFilter implements a simple digital low-pass filter with dynamically
// adjustable cutoff frequency and resonance.

#include "ResonantLowPassFilter.h"
#include "FunctionTable.h"

namespace AudioKitCore
{
    // To avoid having to call sin() and cos() in setParameters() (whenever filter parameters
    // are changed), we maintain this static sine lookup table.
    static FunctionTable sineTable;
    static float Sine(float phase) { return sineTable.interp_cyclic(phase); }
    static float Cosine(float phase) { return sineTable.interp_cyclic(phase + 0.25f); }

    static const float kMinCutoffHz = 12.0f;
    static const float kMinResLinear = 0.1f;
    static const float kMaxResLinear = 10.0f;
    
    ResonantLowPassFilter::ResonantLowPassFilter()
    {
        init(44100.0);  // sensible guess, will be overridden by init() call anyway

        if (sineTable.pWaveTable == 0)  // build sine table only once
        {
            sineTable.init(2048);
            sineTable.sinusoid();
        }
    }
    
    void ResonantLowPassFilter::init(double sampleRateHz)
    {
        this->sampleRateHz = sampleRateHz;
        x1 = x2 = y1 = y2 = 0.0;
        mLastCutoffHz = mLastResLinear = -1.0;  // force recalc of coefficients
    }
    
    void ResonantLowPassFilter::setParameters(double newCutoffHz, double newResLinear)
    {
        // only calculate the filter coefficients if the parameters have changed from last time
        if (newCutoffHz == mLastCutoffHz && newResLinear == mLastResLinear) return;
        
        if (newCutoffHz < kMinCutoffHz) newCutoffHz = kMinCutoffHz;
        if (newResLinear < kMinResLinear ) newResLinear = kMinResLinear;
        if (newResLinear > kMaxResLinear ) newResLinear = kMaxResLinear;
        
        // convert cutoff from Hz to 0->1 normalized frequency
        double cutoff = 2.0 * newCutoffHz / sampleRateHz;
        if (cutoff > 0.99) cutoff = 0.99;   // clip
        
        mLastCutoffHz = newCutoffHz;
        mLastResLinear = newResLinear;

        double k = 0.5 * newResLinear * Sine(float(0.5 * cutoff));
        double c1 = 0.5 * (1.0 - k) / (1.0 + k);
        double c2 = (0.5 + c1) * Cosine(float(0.5 * cutoff));
        double c3 = (0.5 + c1 - c2) * 0.25;
        
        a0 = 2.0 * c3;
        a1 = 2.0 * 2.0 * c3;
        a2 = 2.0 * c3;
        b1 = 2.0 * -c2;
        b2 = 2.0 * c1;
    }
    
    void ResonantLowPassFilter::process(const float *sourceP, float *destP, int inFramesToProcess)
    {
        while (inFramesToProcess--)
        {
            float inputSample = *sourceP++;
            float outputSample = float(a0*inputSample + a1*x1 + a2*x2 - b1*y1 - b2*y2);

            x2 = x1;
            x1 = inputSample;
            y2 = y1;
            y1 = outputSample;
            
            *destP++ = outputSample;
        }
    }

}
