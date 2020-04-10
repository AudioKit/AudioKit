// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBandPassButterworthFilterParameter) {
    AKBandPassButterworthFilterParameterCenterFrequency,
    AKBandPassButterworthFilterParameterBandwidth,
    AKBandPassButterworthFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createBandPassButterworthFilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBandPassButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKBandPassButterworthFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float bandwidthLowerBound = 0.0;
    float bandwidthUpperBound = 20000.0;

    float defaultCenterFrequency = 2000.0;
    float defaultBandwidth = 100.0;

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
