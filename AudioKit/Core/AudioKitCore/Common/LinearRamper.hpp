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
        float constantValue;    // special case of horizontal ramp
        
        LinearRamper() : value(0.0f), target(0.0f), increment(0.0f), constantValue(flagValue) {}
        
        // initialize to a stable value
        void init(float v)
        {
            value = target = v;
            increment = 0.0f;
            constantValue = flagValue;
        }
        
        // initialize all parameters
        void init(float startValue, float targetValue, float intervalSamples)
        {
            constantValue = flagValue;  // assume startValue != targetValue
            target = targetValue;
            if (intervalSamples < 1.0f)
            {
                // target has already been hit, we're already done
                value = target;
                increment = 0.0f;
            }
            else if (startValue == targetValue)
            {
                // special case of horizontal ramp
                constantValue = startValue; // remember the constant value here
                value = 0.0f;               // and let value
                increment = 1.0f;           // count samples
                target = intervalSamples;   // to time the interval
            }
            else
            {
                // normal case: value ramps to target
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
            value += increment;
            return (constantValue == flagValue) ? value : constantValue;
        }
        
        inline void getValues(int count, float* pOut)
        {
            for (int i=0; i < count; i++) *pOut++ = getNextValue();
        }
    };

}
