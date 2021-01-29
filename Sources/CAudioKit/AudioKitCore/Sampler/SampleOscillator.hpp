// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#include <math.h>

#include "SampleBuffer.hpp"

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4018) // more "signed/unsigned mismatch"
#pragma warning(disable:4100) // unreferenced formal parameter
#pragma warning(disable:4101) // unreferenced local variable
#pragma warning(disable:4245) // 'return': conversion from 'int' to 'size_t', signed/unsigned mismatch
#pragma warning(disable:4267) // conversion from... possible loss of data
#pragma warning(disable:4305) // truncation from 'double' to 'float'
#pragma warning(disable:4309) // truncation of constant value
#pragma warning(disable:4334) // result of 32-bit shift implicitly converted to 64 bits
#pragma warning(disable:4456) // Declaration hides previous local declaration
#pragma warning(disable:4458) // declaration ... hides class member
#pragma warning(disable:4505) // unreferenced local function has been removed
#endif

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
