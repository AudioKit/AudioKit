//
//  AdjustableDelayLine.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

namespace AudioKitCore
{
    class AdjustableDelayLine {
        double sampleRateHz;
        double maxDelayMs;
        float fbFraction;
        float *pBuffer;
        int capacity;
        int writeIndex;
        float readIndex;
        float output;
        
    public:
        AdjustableDelayLine();
        ~AdjustableDelayLine() { deinit(); }
        
        void init(double sampleRate, double maxDelayMilliseconds);
        void deinit();
        
        void clear();

        double getMaxDelayMs() { return maxDelayMs; }

        void setDelayMs(double delayMs);
        void setFeedback(float feedback) { fbFraction = feedback; }
 
        float push(float sample);

        float getOutput() { return output; }
    };
    
}
