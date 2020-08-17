// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#include <math.h>

#include "SampleBuffer.hpp"

namespace AudioKitCore
{

    struct SampleOscillator
    {
        bool isLooping;     // true until note released
        double indexPoint;  // use double so we don't lose precision when indexPoint becomes much larger than increment
        double increment;   // 1.0 = play at original speed
        double multiplier;  // multiplier applied to increment for pitch bend, vibrato
        
        void setPitchOffsetSemitones(double semitones) { multiplier = pow(2.0, semitones/12.0); }
        
        // return true if we run out of samples
        inline bool getSample(SampleBuffer *sampleBuffer, int sampleCount, float *output, float gain)
        {
            if (sampleBuffer == NULL || indexPoint > sampleBuffer->endPoint) return true;
            *output = sampleBuffer->interp(indexPoint, gain);
            
            indexPoint += multiplier * increment;
            if (sampleBuffer->isLooping && isLooping)
            {
                if (indexPoint > sampleBuffer->loopEndPoint)
                    indexPoint = indexPoint - sampleBuffer->loopEndPoint + sampleBuffer->loopStartPoint;
            }
            return false;
        }
        
        // return true if we run out of samples
        inline bool getSamplePair(SampleBuffer *sampleBuffer, int sampleCount, float *leftOutput, float *rightOutput, float gain)
        {
            if (sampleBuffer == NULL || indexPoint > sampleBuffer->endPoint) return true;
            sampleBuffer->interp(indexPoint, leftOutput, rightOutput, gain);
            
            indexPoint += multiplier * increment;
            if (sampleBuffer->isLooping && isLooping)
            {
                if (indexPoint > sampleBuffer->loopEndPoint)
                    indexPoint = indexPoint - sampleBuffer->loopEndPoint + sampleBuffer->loopStartPoint;
            }
            return false;
        }
    };

}
