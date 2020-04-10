// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaseLockedVocoderParameter) {
    AKPhaseLockedVocoderParameterPosition,
    AKPhaseLockedVocoderParameterAmplitude,
    AKPhaseLockedVocoderParameterPitchRatio,
    AKPhaseLockedVocoderParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createPhaseLockedVocoderDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaseLockedVocoderDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKPhaseLockedVocoderDSP();

    float positionLowerBound = 0.0;
    float positionUpperBound = 1000.0;
    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 1.0;
    float pitchRatioLowerBound = 0.0;
    float pitchRatioUpperBound = 1000.0;

    float defaultPosition = 0.0;
    float defaultAmplitude = 1.0;
    float defaultPitchRatio = 1.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void start() override;

    void setUpTable(float *table, UInt32 size) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
