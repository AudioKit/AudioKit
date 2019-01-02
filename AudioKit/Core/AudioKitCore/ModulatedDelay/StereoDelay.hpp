//
//  StereoDelay.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include "AdjustableDelayLine.hpp"

namespace AudioKitCore
{
    class StereoDelay {
        double sampleRateHz;
        float feedbackFraction;
        float dryWetMixFraction;
        bool pingPongMode;

        AdjustableDelayLine delayLine1, delayLine2;
        
    public:
        StereoDelay() : feedbackFraction(0.0f), dryWetMixFraction(0.5f), pingPongMode(false) {}
        ~StereoDelay() { deinit(); }
        
        void init(double sampleRate, double maxDelayMs);
        void deinit();
        
        void clear();
        
        void setPingPongMode(bool pingPong);
        void setDelayMs(double delayMs);
        void setFeedback(float fraction);
        void setDryWetMix(float fraction);
        
        bool getPingPongMode() { return pingPongMode; }

        void render(int sampleCount, const float *inBuffers[], float *outBuffers[]);
    };
    
}
