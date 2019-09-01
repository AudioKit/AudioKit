//
//  LinearRamper.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

namespace AudioKitCore
{
    
    struct LinearRamper
    {
        static float constexpr flagValue = 100000.0f;

        float value;            // current value
        float target;           // where it is headed
        float increment;        // per-sample increment
        int count;              // counts down samples
        
        LinearRamper() : value(0.0f), target(0.0f), increment(0.0f), count(0) {}
        
        // initialize to a stable value
        void init(float v)
        {
            value = target = v;
            increment = 0.0f;
            count = 0;
        }
        
        // initialize all parameters
        void init(float startValue, float targetValue, int intervalSamples)
        {
            count = intervalSamples;  // assume startValue != targetValue
            target = targetValue;
            if (count < 1)
            {
                // target has already been hit, we're already done
                value = target;
                increment = 0.0f;
            }
            else
            {
                // normal case: value ramps to target
                value = startValue;
                increment = (target - value) / count;
            }
        }
        
        // reset new target and new interval, retaining current value
        inline void reinit(float targetValue, int intervalSamples)
        {
            init(value, targetValue, intervalSamples);
        }
        
        inline float isRamping()
        {
            return count > 0;
        }
        
        inline float getNextValue()
        {
            if (count > 0)
            {
                value += increment;
                count--;
            }
            return value;
        }
        
        inline void getValues(int nValuesNeeded, float *pOut)
        {
            for (int i=0; i < nValuesNeeded; i++) *pOut++ = getNextValue();
        }
    };

}
