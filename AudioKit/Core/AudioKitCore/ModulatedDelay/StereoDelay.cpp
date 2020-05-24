// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "StereoDelay.hpp"

namespace AudioKitCore
{
    void StereoDelay::init(double sampleRate, double maxDelayMs)
    {
        delayLine1.init(sampleRate, maxDelayMs);
        delayLine2.init(sampleRate, maxDelayMs);
    }
    
    void StereoDelay::deinit()
    {
        delayLine1.deinit();
        delayLine2.deinit();
    }
    
    void StereoDelay::clear()
    {
        delayLine1.clear();
        delayLine2.clear();
    }
    
    void StereoDelay::setPingPongMode(bool pingPong)
    {
        pingPongMode = pingPong;
        setFeedback(feedbackFraction);
    }

    void StereoDelay::setDelayMs(double delayMs)
    {
        delayLine1.setDelayMs(delayMs);
        delayLine2.setDelayMs(delayMs);
    }

    void StereoDelay::setFeedback(float fraction)
    {
        feedbackFraction = fraction;
        delayLine1.setFeedback(pingPongMode ? 0.0f : fraction);
        delayLine2.setFeedback(pingPongMode ? 0.0f : fraction);
    }
    
    void StereoDelay::setDryWetMix(float fraction)
    {
        dryWetMixFraction = fraction;
    }

    void StereoDelay::render(int sampleCount, const float *inBuffers[], float *outBuffers[])
    {
        if (pingPongMode)
        {
            for (int i = 0; i < sampleCount; i++)
            {
                float inputSample = 0.5f * (inBuffers[0][i] + inBuffers[1][i]);
                float leftSample = delayLine1.push(inputSample + feedbackFraction * delayLine2.getOutput());
                float rightSample = delayLine2.push(leftSample);

                outBuffers[0][i] = (1.0f - dryWetMixFraction) * leftSample + dryWetMixFraction * inBuffers[0][i];
                outBuffers[1][i] = (1.0f - dryWetMixFraction) * rightSample + dryWetMixFraction * inBuffers[1][i];
            }
        }
        else
        {
            for (int i = 0; i < sampleCount; i++)
            {
                float leftSample = delayLine1.push(inBuffers[0][i]);
                float rightSample = delayLine2.push(inBuffers[1][i]);

                outBuffers[0][i] = (1.0f - dryWetMixFraction) * leftSample + dryWetMixFraction * inBuffers[0][i];
                outBuffers[1][i] = (1.0f - dryWetMixFraction) * rightSample + dryWetMixFraction * inBuffers[1][i];
            }
        }
    }
}
