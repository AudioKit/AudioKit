//
//  SampleOscillator.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include <math.h>

#include "SampleBuffer.hpp"
#include "ADSREnvelope.hpp"

namespace AudioKitCore
{

    struct SampleOscillator
    {
        bool bLooping;      // true until note released
        double fIndex;      // use double so we don't lose precision when fIndex becomes much larger than fIncrement
        double fIncrement;  // 1.0 = play at original speed
        double fIncMul;     // multiplier applied to increment for pitch bend, vibrato
        
        void setPitchOffsetSemitones(double semitones) { fIncMul = pow(2.0, semitones/12.0); }
        
        // return true if we run out of samples
        inline bool getSample(SampleBuffer* pSampleBuffer, int nSamples, float* pOut, float gain)
        {
            if (pSampleBuffer == NULL || fIndex > pSampleBuffer->fEnd) return true;
            *pOut = pSampleBuffer->interp(fIndex, gain);
            
            fIndex += fIncMul * fIncrement;
            if (pSampleBuffer->bLoop && bLooping)
            {
                if (fIndex >= pSampleBuffer->fLoopEnd)
                    fIndex = fIndex - pSampleBuffer->fLoopEnd + pSampleBuffer->fLoopStart;
            }
            return false;
        }
        
        // return true if we run out of samples
        inline bool getSamplePair(SampleBuffer* pSampleBuffer, int nSamples, float* pOutLeft, float* pOutRight, float gain)
        {
            if (pSampleBuffer == NULL || fIndex > pSampleBuffer->fEnd) return true;
            pSampleBuffer->interp(fIndex, pOutLeft, pOutRight, gain);
            
            fIndex += fIncMul * fIncrement;
            if (pSampleBuffer->bLoop && bLooping)
            {
                if (fIndex >= pSampleBuffer->fLoopEnd)
                    fIndex = fIndex - pSampleBuffer->fLoopEnd + pSampleBuffer->fLoopStart;
            }
            return false;
        }
    };

}
