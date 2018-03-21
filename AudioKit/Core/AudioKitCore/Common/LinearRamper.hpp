//
//  LinearRamper.hpp
//  AudioKit Core
//
//  Created by Shane Dunne on 2018-03-04.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

namespace AudioKitCore
{
    
    struct LinearRamper
    {
        float value;        // current value
        float target;       // where it is headed
        float increment;    // per-sample increment
        
        LinearRamper() : value(0.0f), target(0.0f), increment(0.0f) {}
        
        // initialize to a stable value
        void init(float v)
        {
            value = target = v;
            increment = 0.0f;
        }
        
        // initialize all parameters
        void init(float startValue, float targetValue, float intervalSamples)
        {
            target = targetValue;
            if (intervalSamples < 1.0f)
            {
                value = target;
                increment = 0.0f;
            }
            else
            {
                value = startValue;
                increment = (target - value) / intervalSamples;
            }
        }
        
        // reset new target and new interval, retaining current value
        inline void reinit(float targetValue, float intervalSamples)
        {
            init(value, targetValue, intervalSamples);
        }
        
        inline float isRamping()
        {
            if (increment == 0.0f) return false;
            if (increment > 0.0f) return value < target;
            else return value > target;
        }
        
        inline float getNextValue()
        {
            return value += increment;
        }
        
        inline void getValues(int count, float* pOut)
        {
            for (int i=0; i < count; i++) *pOut++ = value += increment;
        }
    };

}
