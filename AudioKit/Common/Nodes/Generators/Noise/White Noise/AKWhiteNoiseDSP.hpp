// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKWhiteNoiseParameter) {
    AKWhiteNoiseParameterAmplitude,
    AKWhiteNoiseParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createWhiteNoiseDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKWhiteNoiseDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKWhiteNoiseDSP();

    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 1.0;

    float defaultAmplitude = 1;

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
