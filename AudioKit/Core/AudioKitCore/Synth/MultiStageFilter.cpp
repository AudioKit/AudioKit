// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// MultiStageFilter implements a simple digital low-pass filter with dynamically
// adjustable cutoff frequency and resonance.

#include "MultiStageFilter.hpp"
#include "FunctionTable.hpp"
#include <math.h>

namespace AudioKitCore
{
    MultiStageFilter::MultiStageFilter()
    {
        for (int i=0; i < maxStages; i++) stage[i].init(44100.0);
        stages = 1;
    }
    
    void MultiStageFilter::init(double sampleRateHz)
    {
        for (int i=0; i < maxStages; i++) stage[i].init(sampleRateHz);
    }

    void MultiStageFilter::setStages(int nStages)
    {
        if (nStages < 0) nStages = 0;
        if (nStages > maxStages) nStages = maxStages;
        stages = nStages;

        for (int i=1; i < stages; i++)
            stage[i].setParameters(stage[0].mLastCutoffHz, stage[0].mLastResLinear);
    }
    
    void MultiStageFilter::setParameters(double newCutoffHz, double newResLinear)
    {
        for (int i=0; i < stages; i++) stage[i].setParameters(newCutoffHz, newResLinear);
    }
    
    float MultiStageFilter::process(float sample)
    {
        for (int i=0; i < stages; i++)
            sample = stage[i].process(sample);
        return sample;
    }

}
