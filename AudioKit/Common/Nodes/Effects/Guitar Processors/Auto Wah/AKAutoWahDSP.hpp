// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAutoWahParameter) {
    AKAutoWahParameterWah,
    AKAutoWahParameterMix,
    AKAutoWahParameterAmplitude,
    AKAutoWahParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createAutoWahDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAutoWahDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKAutoWahDSP();

    float wahLowerBound = 0.0;
    float wahUpperBound = 1.0;
    float mixLowerBound = 0.0;
    float mixUpperBound = 1.0;
    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 1.0;

    float defaultWah = 0.0;
    float defaultMix = 1.0;
    float defaultAmplitude = 0.1;

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
