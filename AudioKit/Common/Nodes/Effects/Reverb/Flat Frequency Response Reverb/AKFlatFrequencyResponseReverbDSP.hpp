// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFlatFrequencyResponseReverbParameter) {
    AKFlatFrequencyResponseReverbParameterReverbDuration,
};

#ifndef __cplusplus

AKDSPRef createFlatFrequencyResponseReverbDSP(void);

void setLoopDurationFlatFrequencyResponseReverbDSP(AKDSPRef dsp, float duration);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFlatFrequencyResponseReverbDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKFlatFrequencyResponseReverbDSP();

    void setLoopDuration(float duration);

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
