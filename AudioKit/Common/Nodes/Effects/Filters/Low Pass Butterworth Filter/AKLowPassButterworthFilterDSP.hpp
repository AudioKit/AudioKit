// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKLowPassButterworthFilterParameter) {
    AKLowPassButterworthFilterParameterCutoffFrequency,
    AKLowPassButterworthFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createLowPassButterworthFilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKLowPassButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKLowPassButterworthFilterDSP();

    float cutoffFrequencyLowerBound = 12.0;
    float cutoffFrequencyUpperBound = 20000.0;

    float defaultCutoffFrequency = 1000.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
