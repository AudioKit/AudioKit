// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifdef __cplusplus
#pragma once

#include "AKModulatedDelay_Typedefs.h"

#import <memory>

class AKModulatedDelay
{
public:
    AKModulatedDelay(AKModulatedDelayType type);
    ~AKModulatedDelay();
    
    void init(int channelCount, double sampleRate);
    void deinit();
    
    void setModFrequencyHz(float freq);
    float getModFrequencyHz() { return modFreqHz; }
    
    void setModDepthFraction(float fraction) { modDepthFraction = fraction; }
    float getModDepthFraction() { return modDepthFraction; }
    
    void setLeftFeedback(float feedback);
    void setRightFeedback(float feedback);
    
    void setDryWetMix(float mix) { dryWetMix = mix; }
        
    void Render(unsigned channelCount, unsigned sampleCount, float *inBuffers[], float *outBuffers[]);
    
protected:
    float minDelayMs, maxDelayMs, midDelayMs, delayRangeMs;
    float modFreqHz, modDepthFraction, dryWetMix;
    AKModulatedDelayType effectType;

    struct InternalData;
    std::unique_ptr<InternalData> data;
};

#endif
