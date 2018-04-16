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
        float fbFraction;
        float *pBuffer;
        int capacity;
        int writeIndex;
        float readIndex;
        
    public:
        AdjustableDelayLine();
        ~AdjustableDelayLine() { deinit(); }
        
        void init(double sampleRate, double maxDelayMs);
        void deinit();
        
        void setDelayMs(double delayMs);
        void setFeedback(float feedback);
        float push(float sample);
    };
    
}
