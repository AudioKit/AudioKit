//
//  AKStereoDelay.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStereoDelay.hpp"

namespace AudioKitCore
{
    void AKStereoDelay::init(double sampleRate, double maxDelayMs)
    {
        delayLine1.init(sampleRate, maxDelayMs);
        delayLine2.init(sampleRate, maxDelayMs);
    }
    
    void AKStereoDelay::deinit()
    {
        delayLine1.deinit();
        delayLine2.deinit();
    }
    
    void AKStereoDelay::setPingPongMode(bool pingPong)
    {
        pingPongMode = pingPong;
        setFeedback(feedbackFraction);
    }

    void AKStereoDelay::setDelayMs(double delayMs)
    {
        delayLine1.setDelayMs(delayMs);
        delayLine2.setDelayMs(delayMs);
    }

    void AKStereoDelay::setFeedback(float fraction)
    {
        feedbackFraction = fraction;
        delayLine1.setFeedback(pingPongMode ? 0.0f : fraction);
        delayLine2.setFeedback(pingPongMode ? 0.0f : fraction);
    }
    
    void AKStereoDelay::render(int sampleCount, const float *inBuffers[], float *outBuffers[])
    {
        if (pingPongMode)
        {
            for (int i = 0; i < sampleCount; i++)
            {
                float inputSample = 0.5f * (inBuffers[0][i] + inBuffers[1][i]);
                float leftSample = delayLine1.push(inputSample + feedbackFraction * delayLine2.getOutput());
                float rightSample = delayLine2.push(leftSample);

                outBuffers[0][i] = effectLevelFraction * leftSample + inBuffers[0][i];
                outBuffers[1][i] = effectLevelFraction * rightSample + inBuffers[1][i];
            }
        }
        else
        {
            for (int i = 0; i < sampleCount; i++)
            {
                float leftSample = delayLine1.push(inBuffers[0][i]);
                float rightSample = delayLine2.push(inBuffers[1][i]);

                outBuffers[0][i] = effectLevelFraction * leftSample + inBuffers[0][i];
                outBuffers[1][i] = effectLevelFraction * rightSample + inBuffers[1][i];
            }
        }
    }
}
